require 'helper'

class MySimpleActor < SimpleActor
  def receive(m)
  end
end

class TestAra < Test::Unit::TestCase
  should "create a simple actor" do
    simple_actor = Actor.actor_of(MySimpleActor)
    assert simple_actor != nil
  end
end
