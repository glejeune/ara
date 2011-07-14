$:.unshift("../lib")
require 'ara'

class SimpleMessage < Actor
  def receive(message)
    reply "@ #{Time.now} : Hello #{message}"
  end
end

Ara::Remote.server("localhost", 9292).register("simple_actor", Actors.actor_of(SimpleMessage)).start
