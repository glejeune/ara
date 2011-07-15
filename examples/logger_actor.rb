$:.unshift("../lib")
require 'ara'

# Ara.logger = Logger.new("actor.log")
Ara.debug "Starting..."

class MySimpleActor < SimpleActor
  def receive( message )
    Ara.info "Actor #{self} receive message : #{message}"
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

Ara.debug "Ending..."

# This will raise an exception
begin
  mySimpleActor | "Hum..."
rescue DeadActor => e
  Ara.fatal e.message
end
