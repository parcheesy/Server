#To use TCPServer and TCPSocket classes
require 'socket'
require 'fileutils'

class Server
#Initialize TCPServer object listening on localhost:2345
  def initialize
    @server = TCPServer.new('localhost', 2345)
  end

  def run!(data_path)
    #Loop infinitely
    log_server(data_path)
    begin
      #Should be infinite loop
      #Only 3 times for testing purposes
      #Difficult to test infinite loop without daemonizing process
      2.times do
      
        #Waits for connection to server and returns I/O-like object
        socket = @server.accept
      
        #Read first line of request
        request = socket.gets
      
        #Prints first line of request to console as stderr
        STDERR.puts request
      
        #Define response body to request
        response = "Hello World !\n"
      
        #Define header for response
        header = "HTTP/1.1 200 OK\r\n" +
                 "Content-Type: text/plain\r\n" +
                 "Content-Length: #{response.bytesize}\r\n" +
                 "Connection: close\r\n"
        
        #Blank space between header and body
        header = header + "\r\n"
      
        #Print header and body
        socket.print header
        socket.print response
      
        #Close socket
        socket.close
      end

    rescue Interrupt => e
      puts "Interrupt happened"
    end

    log_server_end
  end

  def log_server(data_path)
    path = data_path + "/hello_log"
    log_file = data_path + "/hello_log/hello_log.txt"
    FileUtils.mkdir(path) unless File.directory?(path)
    FileUtils.touch log_file
    File.open(log_file, 'w') {|file| file.truncate(0)}
    FileUtils.chmod(0644, log_file)
    $stderr.reopen(log_file, 'a')
  end

  def log_server_end
    $stderr.close
  end


end
