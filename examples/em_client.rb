
$:.unshift File.join(File.dirname(__FILE__), '../lib')
require 'messagepipe/client'
require 'messagepipe/transport/eventmachine'


EventMachine::run {
  # TODO: clean this up
  transport = MessagePipe::EventMachineTransport.connect('127.0.0.1', 9191)
  $socket = MessagePipe.new(transport)

  $socket.call_async(:slow) do |msg|
    puts "#{msg} from slow"
  end

  $socket.call_async(:add, 2, 2) do |msg|
    puts "#{msg} from add"
  end
}
