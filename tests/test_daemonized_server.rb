require 'net/http'
require './lib/server'
require "test/unit"

class Testserver < Test::Unit::TestCase

  def test_daemonized_server
    #Run server on its own thread
    Thread.new {
      server = Server.new({logfile: "logfile", pidfile: "pidfile"})
      server.run!
    }
    #Make two requests to server so loop ends
    uri = URI("http://localhost:2345/")
    Net::HTTP.get(uri)
    uri = URI("http://localhost:2345/testing")
    Net::HTTP.get(uri)
    pid = File.read("pidfile").to_i
    Process.kill("QUIT", pid)
    uri = URI("http://localhost:2345/terminating")
    Net::HTTP.get(uri)
    #Read log file
    log_contents = nil
    File.open("logfile") {|f| log_contents=f.read}
    #Check that log file included 'testing' get request
    assert log_contents.include? "testing"
  end

end

