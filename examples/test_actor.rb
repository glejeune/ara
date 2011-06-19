$:.unshift("../lib")
require 'ara'

class MySimpleActor < SimpleActor
  def receive( message )
    id = rand(10)
    puts "I'm actor #{self} with ID##{id}"
    if message.class == Fixnum
      message.times do |i|
        puts "#{id} : #{i}"
        sleep 0.5
      end
    else
      puts "Don't know what to do with your message : #{message}"
    end
  end
end

mySimpleActor = Actors.actor_of(MySimpleActor).start
mySimpleActor | 5
mySimpleActor | "Hello World!"
mySimpleActor | 7
mySimpleActor | 9

puts "Thanks actor!"
sleep 20

mySimpleActor.stop
