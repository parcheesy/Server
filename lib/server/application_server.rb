#### Server for serving up a web application
require 'uri'

module Server

  class ApplicationServer < Server
    attr_reader :server_files    
    attr_reader :controllers
    attr_reader :routes
    # Define directory from where files will be served
    WEB_ROOT = './public'
  
    # Define map from extensions to content type
    CONTENT_TYPE_MAPPING = {
      html: 'text/html',
      js: 'appplication/javascript',
      css: 'text/css',
      txt: 'text/plain',
      png: 'image/png',
      jpg: 'image/jpeg',
    }
  
    # Define a default content type as binary data
    DEFAULT_CONTENT_TYPE = 'application/octet-stream'

    # Overwrite Server Initializer to add file_hash
    def initialize(options)
      super(options)
      @server_files = hash_files
      @routes = {}
      controller_names = read_and_load_controllers
      @controllers = create_controller_hash(controller_names)
      if File.exists?("./routes.rb")
        @routes = eval(File.read("./routes.rb"))
      end
    end

    # Return content type based on file path
    def content_type(path)
      ext = File.extname(path).split(".").last
      CONTENT_TYPE_MAPPING.fetch(ext.to_sym, DEFAULT_CONTENT_TYPE)
    end

    # Parse http request and return file path
    # Security feature to prevent unauthorized access to non-public files
    def requested_path(request_line) 
      request_uri = request_line.split(" ")[1]
      uri = URI(request_uri)
      path = uri.path
      query = uri.query
      parameters = parse_query(query) if query

      clean = []

      parts = path.split("/")
      #Prevent path from having empty, ".", or ".." parts
      parts.each do |part|
        next if part.empty? || part=="."
        part == ".." ? clean.pop : clean << part
      end
      
      if path.include? "."
        return File.join(WEB_ROOT, *clean), nil 
      else
        return File.join(*clean), parameters
      end

    end

    # Run application server
    def run_server(port)

      server = TCPServer.new('localhost', port)
      while !@quit
        socket = server.accept
        request = socket.gets

        $stderr.puts request
        
       
        # Retrieve file path from http request
        path, parameters = requested_path(request)
        # Retrieve proper response from server_files hash based on path
        
        response = path_options(path, parameters)


        socket.print response

        socket.close
      end

    end

    # If file exists in server_files return proper response
    # Otherwise return not_found response
    def path_options(path, params)

      if code = @routes[path]
        response = eval(code) 
        return response
      elsif response = @server_files[path]
        return response
      else
        return not_found
      end

    end
    
    # Create a hash with files in public folder as keys and 
    # full responses as values
    def hash_files
      path = File.join(WEB_ROOT, "**", "*")
      files = Dir.glob(path)
      file_hash = {}
      files.each do |path|
        next if path=="." || path==".." || File.directory?(path)
        File.open(path) do |file|
            file_hash[path] = "HTTP/1.1 200 OK\r\n" +
                              "Content-Type: #{content_type(path)}\r\n" +
                              "Content-Length: #{file.size}\r\n" +
                              "Connection: close\r\n" +
                              "\r\n" +
                              file.read

        end
      end
      return file_hash
    end

    # Block method to allow loading routes from route file within
    # a web application.
    def load_routes
      routes = Routes.new
      yield(routes)
      return routes.server_files
    end
    
    # Create and return not found response
    def not_found
      message = "File not found\n"

      response = "HTTP/1.1 404 Not Found\r\n" +
                 "Content-Type: text/plain\r\n" +
                 "Content-Length: #{message.size}\r\n" +
                 "Connection: close\r\n" +
                 "\r\n" +
                 message

     return response

    end

    def parse_query(query)
      queries = query.split("&")
      queries = queries.map {|query| query.split("=")}
      parameters = {}
      queries.each {|query| parameters[query[0].to_sym] = query[1]}
      return parameters
    end

    def read_and_load_controllers
      controller_files = Dir.glob("./controllers/*.rb")
      controller_names = []
      unless controller_files.empty?
        controller_files.each do |file|
          text = File.read(file)
          /class\s(\w+)/.match text
          controller_names.push($1)
          require file.sub(/\.[^.]+$/, "")
        end
      end
      return controller_names
    end

    def create_controller_hash(controller_names)
      controllers = {}
      controller_names.each do |name|
        controllers[name.to_sym] = Object.const_get(name).new
      end
      return controllers
    end


  end




end
