require 'thread'
require 'binding_of_caller'

class DeadActor < Exception #:nodoc:
end
class UndefinedResultMethod < Exception #:nodoc:
end
class ActorInitializationError < Exception #:nodoc:
end

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

# Actor class
class Actor < SimpleActor
  def initialize #:nodoc:
    raise ActorInitializationError, "You can't initialize Actor directly, use Actors.actor_of" if self.class == ::Actor
    super
    @main = Queue.new
  end

  # Send a synchronous message
  #
  #   myActor = Actors.actor_of(MyActor).start
  #   message = ...
  #   result = myActor << message
  #
  # All code after this call will be executed only when the actor has finished it's work
  def <<(message)
    if @thread.alive?
      @actorQueue << message
      @main.pop
    else 
      raise DeadActor, "Actor is dead!"
    end
  end
  alias :sync_message :<<

  # Send an asynchronous message
  #
  #   myActor = Actors.actor_of(MyActor).start
  #   message = ...
  #   myActor < message
  #
  # The code after this call will be executed without waiting the actor. You must add a <tt>result</tt> method to get the actor' reponse.
  def <(message, reponse_method = nil)
    if @thread.alive?
      @actorQueue << message
      BindingOfCaller.binding_of_caller do |bind|
         self_of_caller = eval("self", bind)
         Thread.new do
            _result = @main.pop
            if block_given?
              yield _result
            elsif response_method != nil
              self_of_caller.send( response_method.to_sym, _result )
            else
              self_of_caller.send( :actor_response, _result )
            end
         end
      end
    else
      raise DeadActor, "Actor is dead!"
    end
  end
  alias :async_message :<

  private
  # Method use by the actor to reply to his sender
  #
  #   class MyActor < Actor
  #     def receive(message)
  #       ...
  #       something = ...
  #       reply( something )
  #     end
  #   end
  def reply( r )
    @main << r
  end
end

# Actors class
class Actors
  # Create a new Actor with class klass
  #
  #   class MyActor < Actor
  #     def receive(message)
  #       ...
  #     end
  #   end
  #   
  #   myActor = Actors.actor_of(MyActor)
  def self.actor_of(klass)
    return klass.new()
  end
end

