require 'eventmachine'

class MessagePipe
  class EventMachineTransport < EventMachine::Connection

    def self.connect(server, port, options = {})
      EM.connect(server, port, self, options)
    end

    def initialize(*args)
      super
      @requests = {}
      @unpacker = MessagePack::Unpacker.new # TODO: cleanup duplication from MessagePipe#new
    end

    def receive_data(data)
      @unpacker.feed(data)
      @unpacker.each { |response|
        if callback = @requests[response[1]]
          callback.call(response)
        end
      }
    end

    def write_async(msg, &block)
      # use Deferrable here?
      @requests[msg[1]] = block
      send_data(msg.to_msgpack)
    end
  end
end
