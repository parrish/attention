require 'redis'
require 'attention/version'
require 'attention/redis_pool'
require 'attention/subscriber'
require 'attention/instance'

module Attention
  class << self
    attr_accessor :options
    attr_reader :instance
  end

  self.options = {
    namespace: 'attention',                # Redis key namespace
    ttl: 60,                               # Heartbeat TTL in seconds
    redis_url: 'redis://localhost:6379/0', # Redis connection string
    pool_size: 5,                          # Size of the publishing Redis pool
    timeout: 5                             # Redis connection timeout
  }

  def self.redis
    RedisPool.instance
  end

  def self.announce
    @instance ||= Instance.new
    instance.publish
  end

  def self.instances
    resolve ips_for instance_keys
  end

  def self.instance_keys
    redis.call.keys 'instance_*'
  end

  def self.ips_for(keys)
    [].tap do |list|
      redis.call.multi do |multi|
        keys.each do |key|
          list << [key, multi.get(key)]
        end
      end
    end
  end

  def self.resolve(list)
    list.map do |key, future|
      [key, future.value]
    end.to_h
  end
end
