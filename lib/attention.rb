require 'redis'
require 'attention/version'
require 'attention/redis_pool'
require 'attention/subscriber'
require 'attention/blocking_subscriber'
require 'attention/instance'

# The top-level API
# 
# Default options:
#   {
#     namespace: 'attention',                # Redis key namespace
#     ttl: 60,                               # Instance heartbeat TTL in seconds
#     redis_url: 'redis://localhost:6379/0', # Redis connection string
#     pool_size: 5,                          # Size of the publishing Redis pool
#     timeout: 5                             # Redis connection timeout
#   }
module Attention
  class << self
    # Configuration options
    attr_accessor :options

    # The server {Instance}
    attr_reader :instance
  end

  self.options = {
    namespace: 'attention',                # Redis key namespace
    ttl: 60,                               # Instance heartbeat TTL in seconds
    redis_url: 'redis://localhost:6379/0', # Redis connection string
    pool_size: 5,                          # Size of the publishing Redis pool
    timeout: 5                             # Redis connection timeout
  }

  # Provides access to the {RedisPool} connections
  # @return [Redis] A Redis connection
  def self.redis
    RedisPool.instance
  end

  # Publishes this server {Instance}
  # @param ip [String] Optionally override the IP of the server
  # @param port [Fixnum, Numeric] Optionally specify the port of the server
  # @return [Instance] This server instance
  # @see Instance#publish
  def self.activate(ip: nil, port: nil)
    @instance ||= Instance.new ip: ip, port: port
    instance.publish
    instance
  end

  # Unpublishes this server {Instance}
  # @see Instance#unpublish
  def self.deactivate
    @instance.unpublish if @instance
  end

  # Uses a {Subscriber} to listen to changes to {Instance} statuses
  # @yield The callback triggered on {Instance} changes
  # @yieldparam change [Hash] The change event
  # @yieldparam instances [Array<Hash>] The list of active {Instance}s
  # @see Instance Format of the change events
  # @see .instances Format of the instance information
  def self.on_change(&callback)
    Subscriber.new('instance') do |channel, change|
      callback.call change, instances
    end
  end

  # A list of the active {Instance}s
  # @return [Array<Hash>]
  #  [
  #    { 'id' => '1', 'ip' => '127.0.0.1', 'port' => 3000 },
  #    { 'id' => '2', 'ip' => '127.0.0.1', 'port' => 3001 }
  #  ]
  def self.instances
    resolve info_for instance_keys
  end

  # Finds instance keys
  # @!visibility private
  def self.instance_keys
    redis.call.keys 'instance_*'
  end

  # Maps the Redis key +get+s into a multi operation
  # @!visibility private
  def self.info_for(keys)
    [].tap do |list|
      redis.call.multi do |multi|
        keys.each do |key|
          list << multi.get(key)
        end
      end
    end
  end

  # Resolves the list of future values from the multi operation
  # @!visibility private
  def self.resolve(list)
    list.map do |future|
      JSON.parse future.value
    end
  end

  # Attempt to remove this instance when the server shuts down
  at_exit{ deactivate }
end
