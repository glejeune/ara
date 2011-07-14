$:.unshift("../lib")
require 'ara'

class MySimpleActor < SimpleActor
  def receive( message )
    puts "Actor #{self} receive message : #{message}"
  end
end

my_actor = Actors.actor_of(MySimpleActor).start

sched_one = Scheduler.schedule(my_actor, "Hello World! (every 1 second)", 1, 1, Scheduler::SECOND)
sched_two = Scheduler.schedule_once(my_actor, "Hello World! (once after 4 second)", 4, Scheduler::SECOND)

sleep 10

sched_one.shutdown
puts "-- Scheduler has been shutdown! We wait 5 second to be sure ;)"

sleep 5

my_actor.stop
