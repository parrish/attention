require 'socket'
require 'attention/publisher'
require 'attention/timer'

module Attention
  class Instance
    attr_reader :id, :publisher

    def initialize(ip: nil, port: nil)
      @id = Attention.redis.call.incr('instances').to_s
      @ip = ip
      @port = port
      @publisher = Publisher.new 'instance'
    end

    def publish
      redis = Attention.redis.call
      redis.setex "instance_#{ @id }", Attention.options[:ttl], ip
      publisher.publish added: info
      heartbeat
    end

    def unpublish
      return unless @heartbeat
      Attention.redis.call.del "instance_#{ @id }"
      publisher.publish removed: info
      @heartbeat.stop
      @heartbeat = nil
    end

    def info
      { id: @id, ip: ip }.tap do |h|
        h[:port] = @port if @port
      end
    end

    private

    def heartbeat
      @heartbeat ||= Timer.new(heartbeat_frequency) do
        Attention.redis.call.expire "instance_#{ @id }", Attention.options[:ttl]
      end
    end

    def heartbeat_frequency
      [1, Attention.options[:ttl] - 5].max
    end

    def ip
      return @ip if @ip
      address = Socket.ip_address_list.find &:ipv4_private?
      @ip = address && address.ip_address
    end
  end
end
