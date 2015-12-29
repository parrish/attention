module Attention
  class Publisher
    attr_reader :key

    def initialize(key)
      @key = key
    end

    def publish(value)
      redis = Attention.redis.call
      redis.publish key, payload_for(value)
      yield redis if block_given?
    end

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
