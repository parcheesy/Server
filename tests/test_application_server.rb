require './lib/server'
require "test/unit"
require 'test_helper'

class TestApplicationServer < Test::Unit::TestCase

  def test_hash_files
    serv = Server::ApplicationServer.new({})
    assert serv.server_files.include? "./public/test.html"
  end

  def test_requested_path
    request_line = "GET /.././../test/path HTTP/1.1"
    serv = Server::ApplicationServer.new({})
    assert_equal "./public/test/path", serv.requested_path(request_line)[0]
  end

  def test_application_server
    Thread.new {
      server = Server::ApplicationServer.new({logfile: "logfile", pidfile: "pidfile", port: "2345"})
      server.run!
    }

    uri = URI('http://localhost:2345/test.html')
    req = URI_request(uri)
    uri2 = URI('http://localhost:2345/test')
    req2 = URI_request(uri2)
    pid = File.read("pidfile").to_i
    Process.kill("QUIT", pid)
    URI_request(uri)
    assert req.is_a?(Net::HTTPSuccess)
    assert req2.is_a?(Net::HTTPSuccess)
  end

  def test_controller_loading
    serv = Server::ApplicationServer.new({})
    assert serv.controllers[:TestController].is_a? TestController
  end

  def test_routes_server
    serv = Server::ApplicationServer.new({})
    res = serv.path_options("/test", {})
    assert res
  end


end

