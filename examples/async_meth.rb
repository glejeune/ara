$:.unshift("../lib")
require 'ara'

class MyASynchronizedActor < Actor
  def receive(message)
    puts "Actor #{self} receive message : #{message}"
    sleep rand(10)
    reply "Thanks @ #{Time.now}!"
  end
end

def my_response(r)
  puts "Actor send me : #{r}"
end

myASynchromizedActor = Actors.actor_of(MyASynchronizedActor).start
myASynchromizedActor.async_message("Hello !", :my_response)

puts "Message send to actor, response will arrive ;)"

12.times do |_|
  puts "I'm the main... And I'm running"
  sleep 1
end

