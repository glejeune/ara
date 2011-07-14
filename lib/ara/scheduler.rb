require 'singleton'

module Scheduler
  def schedule(receive_actor, message, initial_delay_before_send, delay_between_messages, time_unit) 
     action = Action.new(receive_actor, message, initial_delay_before_send, delay_between_messages, time_unit)
     actions.add(action)
     action.start
     yield action if block_given?
  end

  def schedule_once(receiver_actor, message, delay_until_send, time_unit)
     action = Action.new(receive_actor, message, delay_until_send, nil, time_unit)
     actions.add(action)
     action.start
     yield action if block_given?

  end

  def shutdown
     actions.each { |a| a.shutdown }
  end

  def restart
     actions.each { |a| a.restart }
  end

  def stop
     actions.each { |a| a.stop }
  end

  def actions
     Scheduler::Actions.instance
  end

  class Actions #:nodoc:
     include Singleton

     def initialize
        @mutex = Mutex.new
        @actions = Array.new
     end

     def add(a)
        @mutex.synchronize { @actions << a }
     end

     def remove(a)
        @mutex.synchronize { @actions.delete(a) }
     end

     def remove_all
        @mutex.synchronize { @actions.each { |a| @actions.delete(a) } }
     end

     def each(&b) 
        @mutex.synchronize { @actions.each { |a| yield a } }
     end
  end

  class Action
     def initialize(receiver_actor, message, initial_delay, delay, time_unit) #:nodoc:
        @receiver_actor = receiver_actor
        @message = message
        @initial_delay = initial_delay
        @delay = delay
        @time_unit = time_unit

        @once = delay == null
     end

     def start
     end

     def stop
     end

     def restart
     end

     def shutdown
        stop
        Scheduler.actions.remove(self)
     end

     private
     def run
        @receiver_actor | @message
        shutdown if @once
     end
  end
end
