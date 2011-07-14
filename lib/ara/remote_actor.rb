require 'net/http'

class RemoteActor
   def initialize(route, host, port)
      @route = route
      @host = host
      @port = port
   end
   def <<(message)
      Net::HTTP.get(@host, "/#{@route}?message=#{message}", @port)
   end
end
