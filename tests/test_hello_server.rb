#require 'net/http'
#require './lib/server'
#require "test/unit"
#
#class Testserver < Test::Unit::TestCase
#
#  def test_hello_server
#    #Run server on its own thread
#    Thread.new do
#      server = Server.new
#      server.run!("./data")
#    end
#    #Make two requests to server so loop ends
#    uri = URI("http://localhost:2345/")
#    Net::HTTP.get(uri)
#    uri = URI("http://localhost:2345/testing")
#    Net::HTTP.get(uri)
#    #Read log file
#    log_contents = nil
#    File.open("./data/hello_log/hello_log.txt") {|f| log_contents=f.read}
#    #Check that log file included 'testing' get request
#    assert log_contents.include? "testing"
#  end
#
#end
#
