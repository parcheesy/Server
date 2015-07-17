#To use TCPServer and TCPSocket classes
require 'socket'

#Initialize TCPServer object listening on localhost:2345
server = TCPServer.new('localhost', 2345)

#Loop infinitely
loop do

  #Waits for connection to server and returns I/O-like object
  socket = server.accept

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
