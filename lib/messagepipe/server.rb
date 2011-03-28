require 'rubygems'
require 'eventmachine'
require 'msgpack'
require 'benchmark'

# Server that receives MessagePack RPC
class MessagePipeServer < EventMachine::Connection
  REQUEST  = 0x00
  RESPONSE = 0x01

  protected

  def pac
    @pac ||= MessagePack::Unpacker.new  # Stream Deserializer
  end

  def receive_data(data)
    pac.feed(data)
    pac.each do |msg|
      response = nil

      secs = Benchmark.realtime do
        type  = msg[0]
        seqid = msg[1]

        if type != REQUEST
          unbind
          raise 'Bad client'
        end

        # message format: [type, seqid, error_object, result_object]
        response = begin
          [RESPONSE, seqid, nil, receive_object(msg[2,2])]
        rescue => e
          [RESPONSE, seqid, "#{e.class.name}: #{e.message}", nil]
        end
      end

      send_data(response.to_msgpack)

      puts "#{object_id} - #{msg[1]} - #{msg[2]}(#{msg[3].length} args) - [%.4f ms] [#{response[2] ? 'error' : 'ok'}]" % [secs||0]
    end
  end

  def receive_object(msg)
    method, args = *msg

    if method and public_methods.include?(method)
      return __send__(method, *args)
    else
      raise NoMethodError, "no method #{method} found."
    end
  end
end
