$:.unshift("../lib")
require 'ara'

class MyActor < Actor
  def receive(message)
    action = message[0]
    value = message[1]
    case action
      when :mult then
        puts "#{value} * #{value} = #{value * value}"
      when :add then
        puts "#{value} + #{value} = #{value + value}"
      else 
        puts "Don't know what to do with message : #{message}"
    end
  end
end

myActor = Actors.actor_of(MyActor).start

myActor | [:mult, 4]
myActor | [:add, 4]
myActor | [:something, 4]

sleep 2

myActor.stop
