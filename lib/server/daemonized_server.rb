require 'socket'
require 'fileutils'

class Server

  def initialize(options)
    @options = options
    @quit = false

    # daemonization changes working directory to root
    # must expand relative paths to logfile and pidfile before change
    @options[:logfile] = File.expand_path(logfile) if logfile?
    @options[:pidfile] = File.expand_path(pidfile) if pidfile?
  end

  # run server using options
  def run!
    check_pid
    daemonize if daemonize?
    write_pid
    trap_signals
  
    if logfile?
      redirect_output
    elsif daemonize?
      suppress_output
    end

    run_server

    puts "Shutting down server."
    $stdout = STDOUT
    puts "Shutting down server."
  end

private
  #Option-free server method
  def run_server
    @server = TCPServer.new('localhost', 2345)
    while !@quit
      socket = @server.accept

      request = socket.gets

      $stderr.puts request

      response = "Hello World!\n"

      header = "HTTP/1.1 200 OK\r\n" +
               "Content-Type: text/plain\r\n" +
               "Content-Length: #{response.bytesize}\r\n" +
               "Connection: close\r\n"

      header = header + "\r\n"

      socket.print header
      socket.print response

      socket.close
    end
  end
  
  
  def daemonize?
    @options[:daemonize]
  end

  def logfile
    @options[:logfile]
  end

  def pidfile
    @options[:pidfile]
  end

  def logfile?
    !logfile.nil?
  end

  def pidfile?
    !pidfile.nil?
  end

  #Method that allows daemonization
  def daemonize
    #Forks and exits out of parent process 
    exit if fork
    #Sets process as session and group leader
    Process.setsid
    #Forks and exits out of process again to isolate new process from terminal
    exit if fork
    #Change directory of daemon process to root so isn't affected by directories getting deleted
    Dir.chdir '/'
  end

  def write_pid
    if pidfile?
      begin
        #Create pidfile and throw Errno:EEXIST if it already exists
        #Write pid to pidfile 
        File.open(pidfile, File::WRONLY|File::CREAT|File::EXCL) { |f| f.write("#{Process.pid}") }
        at_exit { File.delete(pidfile) if File.exists?(pidfile) }
        
      rescue Errno::EEXIST
        #If pidfile already exists run check_pid
        #Will delete if exists
        #Retry write_pid
        check_pid
        retry
      end
    end
  end

  #Check pidfile to see if server is already running
  #Or if pidfile exists even though server is not running
  def check_pid
    if pidfile?
      case pid_status(pidfile)        
      when :running, :not_owned
       puts "A server is already running. Check #{pidfile}"
       exit(1)
      when :dead
        File.delete(pidfile)
      end
    end
  end

  #Check status of pidfile
  def pid_status(pidfile)
    begin
      return :exited unless File.exists?(pidfile)
      pid = File.read(pidfile).to_i
      return :dead if pid==0
      Process.kill(0, pid)
      :running
    rescue Errno::ESRCH
      :dead
    rescue Errno::EPERM
      :not_owned
    end
  end

  #Trap :QUIT Signal to cleanly exit server
  def trap_signals
    trap(:QUIT) do

      @quit=true
    end
  end

  #Change stdout and stderr to logfile
  def redirect_output
    FileUtils.mkdir_p(File.dirname(logfile))
    FileUtils.touch logfile
    File.chmod(0644, logfile)
    $stderr = File.open(logfile, "a")
    $stdout = $stderr
    $stdout.sync = $stderr.sync = true
  end
  
  #option to supress output completely
  #by redirecting stdout and stderr to null
  def suppress_output
    $stderr.reopen('/dev/null', 'a')
    $stdout.reopen($stderr)
  end

end
