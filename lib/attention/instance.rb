require 'socket'

module Attention
  class Instance
    attr_reader :id

    def initialize
      key = "#{ Attention.options[:namespace] }_instances"
      @id = Attention.publishing_redis.call.incr(key).to_s
    end

    def publish
      redis = Attention.publishing_redis.call
      redis.setex instance_key, Attention.options[:ttl], ip
      redis.publish 'instance', @id => ip
    end

    private

    def instance_key
      "#{ Attention.options[:namespace] }_instance_#{ @id }"
    end

    def ip
      return @ip if @ip
      address = Socket.ip_address_list.find &:ipv4_private?
      @ip = address && address.ip_address
    end
  end
end
