#### Routes class that allows the creation of routes
#### between paths and controller actions

module Server

  class Routes
  
    attr_reader :server_files
    
    # Creates server_files hash with keys that will be paths
    # and values that will be controller actions
    def initialize
      @server_files = {}
    end

    # Method for adding a route for guest requests
    # by passing the path, the name of the controller
    # and the name of the action desired 
    def get (path, controller, action)
      # The hash value is stored as a string so that the code can be
      # evaluated when the request is received rather than when it is
      # defined. Wherever the code is run there should be a hash 'params'
      # which contains any parameters sent with the HTTP get request
      # required by the controller action
      @server_files[path] = "@controllers[%q(#{controller}).to_sym].send(%q(#{action}), params)"   
    end

  end



end
