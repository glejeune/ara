require 'ext/binding_of_caller'
require 'ara/exception'

# This class allow you to create simple actors. 
class SimpleActor
  def initialize #:nodoc:
    raise ActorInitializationError, "You can't initialize SimpleActor directly, use Actors.actor_of" if self.class == ::SimpleActor
    @actorQueue = Queue.new
  end

  # Start actor and return it
  #
  #   myActor = Actors.actor_of(MyActor)
  #   myActor.start
  def start
    self.send(:pre_start) if self.respond_to?(:pre_start, true)
    @thread = Thread.new do 
      loop do
        receive(@actorQueue.pop)
      end
    end

    return self
  end

  # Stop actor
  #
  #   myActor = Actors.actor_of(MyActor).start
  #   ...
  #   myActor.stop
  def stop
    @thread.kill
    self.send(:post_stop) if self.respond_to?(:post_stop, true)
  end

  # Send a simple message without expecting any response
  #
  #   myActor = Actors.actor_of(MyActor).start
  #   message = ...
  #   myActor | message
  def |(message)
    if @thread.alive?
      @actorQueue << message
    else 
      raise DeadActor, "Actor is dead!"
    end
  end
  alias :message :|

  private
  # Method receiver for the actor
  #
  # When you create an actor (simple or not) you *must* define a <tt>receive</tt> method.
  #
  #   class MyActor < Actor
  #     def receive(message)
  #       ...
  #     end
  #   end
  def receive(message)
    raise "Define me!"
  end
end
