require 'redis'
require 'attention/version'
require 'attention/redis_pool'

module Attention
  class << self
    attr_accessor :options
    attr_reader :redis
  end

  self.options = {
    namespace: 'attention',                # Redis key namespace
    ttl: 60,                               # Heartbeat TTL in seconds
    redis_url: 'redis://localhost:6379/0', # Redis connection string
    pool_size: 5,                          # Size of the Redis pool
    timeout: 5                             # Redis connection timeout
  }

  @redis = RedisPool.instance
end
