require './lib/server'
require "test/unit"
require 'test_helper'

class TestRoutes < Test::Unit::TestCase

  def test_get
    r = Server::Routes.new
    r.get("/test", "Controller", "find")
    assert_equal r.server_files["/test"], "@controllers[%q(Controller).to_sym].send(%q(find), params)"
  end   


end

