module Attention
  class Publisher
    attr_reader :key

    def initialize(key)
      @key = key
    end

    def publish(value)
      redis = Attention.publishing_redis.call
      redis.publish key, value
      yield redis if block_given?
    end
  end
end
