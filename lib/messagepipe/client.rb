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
    @socket.print(data)
  end

  def open?
    true
  end
end

class MessagePipe
  CMD_CALL = 0x01
  RET_OK   = 0x02
  RET_E    = 0x03

  class RemoteError < StandardError
  end

  def initialize(transport)
    @transport = transport
    @unpacker = MessagePack::Unpacker.new
  end

  def call(method, *args)
    @transport.write([CMD_CALL, method, args].to_msgpack)

    while @transport.open?
      @unpacker.feed(@transport.read)
      @unpacker.each do |msg|
        case msg.first
        when RET_E
          raise RemoteError, msg[1]
        when RET_OK
          return msg[1]
        else
          raise RemoteError, "recieved invalid message: #{msg.inspect}"
        end
      end
    end

    raise RemoteError, 'disconnected'
  end
end
