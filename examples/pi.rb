# VERY UNSTABLE !!!

$:.unshift("../lib")
require 'ara'

class Worker < Actor
   def calculate_pi_for(start, nb_of_elements)
      acc = 0.0
      (start...(start+nb_of_elements)).to_a.each { |i|
         acc += 4.0 * (1 - (i % 2) * 2) / (2 * i + 1)
      }
      acc
   end

   def receive(message)
      r = calculate_pi_for(message[:start], message[:nb_of_elements])
      reply r
   end
end

class Master < Actor
   def receive(message)
      nb_of_workers = message[:nb_of_workers]
      nb_of_elements = message[:nb_of_elements]
      @nb_of_messages = message[:nb_of_messages]

      @pi = 0.0
      @nb_of_results = 1

      actors = []
      nb_of_workers.times { |_|
         actors << Actors.actor_of(Worker).start
      }

      router = Routing.load_balancer_actor(actors)
      @m = Mutex.new
      
      @nb_of_messages.times { |i|
         sleep 0.002
         m = { :start => i * nb_of_elements, :nb_of_elements => nb_of_elements }
         router < m
      }
   end

   def actor_response(message)
      @m.synchronize {
      @pi += message
      Ara.debug("*** Pi estimate : #{@pi}")
      @nb_of_results += 1
      self.stop if @nb_of_results >= @nb_of_messages
      }
   end

   def post_stop
      Ara.debug("Pi estimate : #{@pi}")
   end

   def pre_start
   end
end

def calculate(nb_of_workers, nb_of_elements, nb_of_messages) 
   master = Actors.actor_of(Master).start
   m = { :nb_of_workers => nb_of_workers, :nb_of_elements => nb_of_elements, :nb_of_messages => nb_of_messages }
   master | m
end

calculate(10, 1000, 100)

10.times { sleep 1 }
