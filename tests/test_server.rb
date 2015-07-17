require "./lib/server.rb"
require "test/unit"

class Testserver < Test::Unit::TestCase

  def test_sample 
    assert_equal 4, 2+2
  end

end

