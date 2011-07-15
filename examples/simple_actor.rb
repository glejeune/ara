$:.unshift("../lib")
require 'ara'

class MySimpleActor < SimpleActor
  def receive( message )
    puts "Actor #{self} receive message : #{message}"
  end

  private
  def pre_start
     puts "*** in pre_start"
  end

  private
  def post_stop
     puts "*** in post_stop"
  end
end

mySimpleActor = Actors.actor_of(MySimpleActor).start
mySimpleActor | "Bonjour le monde!"

sleep 1

mySimpleActor | "Hello World!"
mySimpleActor | "Ola Mundo!"

sleep 1

mySimpleActor.stop

sleep 1

# This will raise an exception
begin
  mySimpleActor | "Hum..."
rescue DeadActor => e
  puts e
end
