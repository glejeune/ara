import scala.actors.Actor

case class Mult(value: Int)
case class Add(value: Int)
case class Something(value: Int)
case object Stop

class MyActor extends Actor {
   def act() {
      loop {
         receive {
            case Mult(value) => println(value + " * " + value + " = " + value * value)
            case Add(value) => println(value + " + " + value + " = " + (value + value))
            case Stop => exit()
            case msg => println("Don't know what to do with message :" + msg)
         }
      }
   }
}

val myActor = new MyActor()
myActor.start

myActor ! Mult(4)
myActor ! Add(4)
myActor ! Something(4)

myActor ! Stop
