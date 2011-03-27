$:.unshift File.join(File.dirname(__FILE__), '../lib')
require 'messagepipe/server'

class TestServer < MessagePipeServer

  def add(a, b)
    a + b
  end

  def hi
    'hello'
  end

  def echo(string)
    string
  end

  def throw
    raise StandardError, 'hell'
  end

  private

  def private_method
    'oh no'
  end

end

EventMachine::run do
  EventMachine::start_server "0.0.0.0", 9191, TestServer
end
