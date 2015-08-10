require 'net/http'

class Test::Unit::TestCase

  def URI_request(uri)
    100.times do
      begin
        req = Net::HTTP.get_response(uri)
        return req
      rescue Errno::ECONNREFUSED
        puts "can't connect"
      end
    end
  end


end
