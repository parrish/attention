require 'socket'
require 'attention/publisher'

module Attention
  class Instance
    attr_reader :id, :publisher

    def initialize
      @id = Attention.redis.call.incr('instances').to_s
      @publisher = Publisher.new 'instance'
    end

    def publish
      redis = Attention.redis.call
      redis.setex "instance_#{ @id }", Attention.options[:ttl], ip
      publisher.publish @id => ip
    end

    private

    def ip
      return @ip if @ip
      address = Socket.ip_address_list.find &:ipv4_private?
      @ip = address && address.ip_address
    end
  end
end
