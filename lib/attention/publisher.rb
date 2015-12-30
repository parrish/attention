module Attention
  # Uses Redis pub/sub to publish events
  class Publisher
    # Publishes the value to the channel
    # @param channel [String] The channel to publish to
    # @param value [Object] The value to publish
    # @yield Allows an optional block to use the Redis connection
    # @yieldparam redis [Redis] The Redis connection
    def publish(channel, value)
      redis = Attention.redis.call
      redis.publish channel, payload_for(value)
      yield redis if block_given?
    end

    # Converts published values to JSON if possible
    # @api private
    def payload_for(value)
      case value
      when Array, Hash
        JSON.dump value
      else
        value
      end
    rescue
      value
    end
  end
end
