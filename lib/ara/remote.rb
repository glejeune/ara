require 'rubygems'
require 'rack'

module Rack
 class ActorMap
    def initialize(actor)
       @actor = actor.start
    end

   def call( env )
     response = Rack::Response.new
     request = Rack::Request.new(env)
     message = request.params["message"]
     response.write @actor << message
     response.finish
    end
  end
end

module Ara
   module Remote
      def self.server(host, port)
         return Server.new(host, port)
      end

      class Server
         def initialize(host, port)
            @host = host
            @port = port
            @routes = {}
         end

         def register(route, actor)
            @routes["/#{route}"] = Rack::ActorMap.new(actor)
            self
         end

         def start
            app = Rack::URLMap.new(@routes)
            app = Rack::ContentLength.new(app)
            Rack::Handler::WEBrick.run( app, {:Port => @port} )
         end
      end
   end
end
