require 'redis'
require 'attention/version'
require 'attention/redis_pool'
require 'attention/subscriber'
require 'attention/instance'
require 'attention/timer'

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

  def self.activate(ip: nil, port: nil)
    return if @instance
    @instance = Instance.new ip: ip, port: port
    instance.publish
  end

  def self.deactivate
    @instance.unpublish if @instance
  end

  def self.instances
    resolve info_for instance_keys
  end

  def self.instance_keys
    redis.call.keys 'instance_*'
  end

  def self.info_for(keys)
    [].tap do |list|
      redis.call.multi do |multi|
        keys.each do |key|
          list << multi.get(key)
        end
      end
    end
  end

  def self.resolve(list)
    list.map do |future|
      JSON.parse future.value
    end
  end
end
