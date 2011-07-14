require 'ara/remote_actor'
# Actors class
class Actors
   # Create a new Actor with class klass
   #
   #   class MyActor < Actor
   #     def receive(message)
   #       ...
   #     end
   #   end
   #   
   #   myActor = Actors.actor_of(MyActor)
   def self.actor_of(klass)
      return klass.new()
   end

   def self.actor_for(route, host, port)
      return RemoteActor.new(route, host, port)
   end
end

