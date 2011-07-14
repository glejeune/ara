require 'ara/exception'
require 'ara/simple_actor'

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
  def <(message, response_method = nil)
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
