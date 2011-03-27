require 'test_helper'

class BaseTest < Test::Unit::TestCase

  def setup
    $socket ||= MessagePipe.new(TcpTransport.new('localhost', 9191))
  end

  def test_simple_rpc
    assert_equal 'hello', $socket.call(:hi)
  end

  def test_large_rpc
    data = 'x' * 500_000
    assert_equal data, $socket.call(:echo, data)
  end

  def test_rpc_with_params
    assert_equal 3, $socket.call(:add, 1, 2)
    assert_equal 2000000, $socket.call(:add, 1000000, 1000000)
  end

  def test_throw_exception
    assert_raise(MessagePipe::RemoteError) do
      $socket.call :throw
    end
  end

  def test_cannot_call_non_existing_method
    assert_raise(MessagePipe::RemoteError) do
      $socket.call :does_not_exist
    end
  end

  def test_cannot_call_private_method
    assert_raise(MessagePipe::RemoteError) do
      $socket.call :private_method
    end
  end

end
