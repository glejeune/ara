$:.unshift("../lib")
require 'ara'

class MyASynchronizedActor < Actor
  def receive(message)
    puts "Actor #{self} receive message : #{message}"
    sleep rand(10)
    reply "Thanks @ #{Time.now}!"
  end
end

def actor_response(r)
  puts "Actor send me : #{r}"
end

myASynchromizedActor = Actor.actor_of(MyASynchronizedActor).start
myASynchromizedActor < "Hello !"

puts "Message send to actor, response will arrive ;)"

12.times do |_|
  puts "I'm the main... And I'm running"
  sleep 1
end

