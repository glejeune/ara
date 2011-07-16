$:.unshift("../lib")
require 'ara'

class MySynchronizedActor < Actor
  def receive(message)
    puts "Actor #{self} receive message : #{message} and take a break..."
    sleep rand(10)
    reply "Thanks @ #{Time.now}!"
  end
end

mySynchromizedActor = Actors.actor_of(MySynchronizedActor).start
puts mySynchromizedActor << "Hello !"
