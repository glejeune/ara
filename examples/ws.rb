$:.unshift("../lib")
require 'ara'

class SimpleMessage < Actor
  def receive(message)
    reply "#{message} : Thanks @ #{Time.now}!"
  end
end

Ara::Remote.server("localhost", 9292).register("simple_actor", Actors.actor_for(SimpleMessage)).start
