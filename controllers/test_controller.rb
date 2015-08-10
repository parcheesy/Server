class TestController
  attr_reader :test

  def test_method(params)
   @test = true
   return @test
  end



end
