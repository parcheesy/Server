require 'net/http'
require './lib/server'
require "test/unit"

class Testserver < Test::Unit::TestCase

  def test_hello_server
    Thread.new do
      server = Server.new
      server.run!("./data")
    end
    
    uri = URI("http://localhost:2345/")
    Net::HTTP.get(uri)
    uri = URI("http://localhost:2345/testing")
    Net::HTTP.get(uri)
    y = nil
    File.open("./data/hello_log/hello_log.txt") {|f| y=f.read}
    assert y.include? "testing"
  end

end

