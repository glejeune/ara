class Scheduler
  def schedule(receive_actor, message, initial_delay_before_send, delay_between_messages, time_unit, &block) 
  end

  def schedule_once(receiver_actor, message, delay_until_send, time_unit, &block)
  end

  def shutdown
  end

  def restart
  end
end
