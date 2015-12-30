require 'socket'
require 'attention/publisher'
require 'attention/timer'

module Attention
  # A publishable representation of the current server
  # 
  # When an instance is {#publish}ed, an event is sent in the format
  #   {
  #      'added' => {
  #        'id' => '123',
  #        'ip' => '127.0.0.1',
  #        'port' => 9000
  #      }
  #   }
  # 
  # When an instance is {#unpublish}ed, an event is sent in the format
  #   {
  #      'removed' => {
  #        'id' => '123',
  #        'ip' => '127.0.0.1',
  #        'port' => 9000
  #      }
  #   }
  class Instance
    attr_reader :id

    # @!visibility private
    attr_reader :publisher

    # Creates an Instance
    # @param ip [String] Optionally override the IP of the server
    # @param port [Fixnum, Numeric] Optionally specify the port of the server
    def initialize(ip: nil, port: nil)
      @id = Attention.redis.call.incr('instances').to_s
      @ip = ip
      @port = port
      @publisher = Publisher.new
    end

    # Publishes this server and starts the {#heartbeat}
    def publish
      publisher.publish('instance', added: info) do |redis|
        redis.setex "instance_#{ @id }", Attention.options[:ttl], JSON.dump(info)
      end
      heartbeat
    end

    # Unpublishes this server and stops the {#heartbeat}
    def unpublish
      return unless @heartbeat
      publisher.publish('instance', removed: info) do |redis|
        redis.del "instance_#{ @id }"
      end
      @heartbeat.stop
      @heartbeat = nil
    end

    # Published information about this instance
    # @return [Hash<id: Fixnum, ip: String, port: Numeric>]
    # @option @return [Fixnum] :id The instance id
    def info
      { id: @id, ip: ip }.tap do |h|
        h[:port] = @port if @port
      end
    end

    private

    # Uses a {Timer} to periodically tell Redis that this
    # server is still online
    # @!visibility public
    # @api private
    def heartbeat
      @heartbeat ||= Timer.new(heartbeat_frequency) do
        Attention.redis.call.expire "instance_#{ @id }", Attention.options[:ttl]
      end
    end

    # The frequency of the {#heartbeat} is based on Attention.options[:ttl]
    # @!visibility public
    # @api private
    def heartbeat_frequency
      [1, Attention.options[:ttl] - 5].max
    end

    # Attempts to automatically discover the IP address of the server
    def ip
      return @ip if @ip
      address = Socket.ip_address_list.find &:ipv4_private?
      @ip = address && address.ip_address
    end
  end
end
