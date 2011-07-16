module Routing 
   def self.load_balancer_actor(actors)
      router = Actors.actor_of(Dispatcher).start
      router | ActorList.new(actors)
      router
   end

   def self.Broadcast(message)
      return B.new(message)
   end

   class B #:nodoc:
      def initialize(message)
         @message = message
      end

      def message
         @message
      end
   end

   class ActorList #:nodoc:
      def initialize(actors)
         @actors = actors
         @free_actors = Queue.new
         @actors.each { |actor| @free_actors << actor }
      end

      def broadcast(message)
         @actors.each do |actor|
            actor | message
         end
      end

      def get_actor
         @free_actors.shift
      end

      def release_actor(actor)
         @free_actors << actor
      end
   end

   class Dispatcher < Actor
      def receive(message)
         if message.instance_of? Routing::ActorList
            @list = message
         elsif message.instance_of? Routing::B
            @list.broadcast(message.message)
         else
            f = @list.get_actor
            unless f.nil?
               f < message
            else 
               Ara.debug("No free actor :(")
            end
         end
      end

      def actor_response_with_name(actor, r)
         @list.release_actor(actor)
         reply r
      end
   end
end
