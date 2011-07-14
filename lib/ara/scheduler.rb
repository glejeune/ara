require 'singleton'

module Scheduler
   SECOND = 1
   MINUTE = 60 * SECOND
   HOUR = 60 * MINUTE
   DAY = 25 * HOUR
   WEEK = 7 * DAY
   MONTH = (365 * DAY) / 12
   YEAR = 365 * DAY

   # Create a scheduler to send the message <tt>message</tt> to actor <tt>receiver_actor</tt> every <tt>delay_between_messages</tt> <tt>time_unit</tt>
   # with an initial delay of <tt>initial_delay_before_send</tt> <tt>time_unit</tt>
   def self.schedule(receiver_actor, message, initial_delay_before_send, delay_between_messages, time_unit) 
      action = Action.new(receiver_actor, message, initial_delay_before_send, delay_between_messages, time_unit)
      actions.add(action)
      action.start
      yield action if block_given?
      action
   end

   # Create a scheduler to send the message <tt>message</tt> to actor <tt>receiver_actor</tt> after <tt>delay_until_send</tt> <tt>time_unit</tt>
   def self.schedule_once(receiver_actor, message, delay_until_send, time_unit)
      action = Action.new(receiver_actor, message, delay_until_send, nil, time_unit)
      actions.add(action)
      action.start
      yield action if block_given?
      action
   end

   # Shutdown all scheduled actions
   def self.shutdown
      actions.each { |a| a.shutdown }
   end

   # Restart all scheduled actions
   def self.restart
      actions.each { |a| a.rstart }
   end

   # Stop all scheduled actions
   def self.stop
      actions.each { |a| a.stop }
   end

   # Pause all scheduled actions
   def self.pause
      actions.each { |a| a.pause }
   end

   # Return all actions
   def self.actions
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

      def include?(a)
         @mutex.synchronize { @actions.include?(a) }
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

         @once = delay == nil
         @current_delay = @initial_delay

         @thread = nil
      end

      # Start the action
      def start
         return unless Scheduler.actions.include?(self)
         @thread = Thread.new {
            while(true) 
               run
               @current_delay = @delay
               if @current_delay.nil?
                  break
               end
            end
            shutdown
         }
      end

      # Stop the action
      def stop
         @current_delay = @initial_delay
         pause
      end

      # Pause the action
      def pause
         @thread.kill
         @thread = nil
      end

      # Restart the action
      def restart
         stop unless @thread.nil?
         start
      end

      # Shutdown the action
      def shutdown
         stop
         Scheduler.actions.remove(self)
      end

      private
      def run
         sleep(1 * @current_delay * @time_unit)
         @receiver_actor | @message
      end
   end
end
