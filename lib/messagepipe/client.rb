require 'rubygems'
require 'eventmachine'
require 'msgpack'
require 'socket'

class TcpTransport
  def initialize(host, port)
    @socket = TCPSocket.open(host, port)
  end

  def read
    @socket.recv(4096)
  end

  def write(data)
    @socket.print(data.to_msgpack)
  end

  def open?
    true
  end
end

class MessagePipe
  REQUEST  = 0x00
  RESPONSE = 0x01

  class RemoteError < StandardError
  end

  def initialize(transport)
    @transport = transport
    @unpacker = MessagePack::Unpacker.new
    @seqid = 0
  end

  def call(method, *args)
    @transport.write([REQUEST, seqid, method, args])

    while @transport.open?
      @unpacker.feed(@transport.read)
      @unpacker.each { |msg| return process_msg(msg) }
    end

    raise RemoteError, 'disconnected'
  end

  def call_async(method, *args)
    @transport.write_async([REQUEST, seqid, method, args]) { |msg| yield process_msg(msg) }
  end

  private

  def process_msg(msg)
    # message format: [type, seqid, error_object, result_object]
    if !msg[2] && msg[0] == RESPONSE
      return msg[3]
    elsif msg[2]
      raise RemoteError, msg[2]
    else
      raise RemoteError, "received invalid message: #{msg.inspect}"
    end
  end

  def seqid
    @seqid += 1
    @seqid = 0 if @seqid >= 1<<31
    return @seqid
  end

end
