$:.unshift("../lib")
require 'ara'

actor = Actors.actor_for("simple_actor", "localhost", 9292)
puts actor << "World"
