require 'redis'
require 'redis-namespace'
require 'connection_pool'

module Attention
  class RedisPool
    attr_reader :pool

    def self.subscribing_instance
      @subscribing_instance ||= new :subscribing
      @subscribing_instance_pool ||= ->{ @subscribing_instance.pool.with{ |redis| redis } }
    end

    def self.publishing_instance
      @publishing_instance ||= new :publishing
      @publishing_instance_pool ||= ->{ @publishing_instance.pool.with{ |redis| redis } }
    end

    private
    def initialize(type)
      pool_config = { size: Attention.options[:pool_size], timeout: Attention.options[:timeout] }

      @pool = ConnectionPool.new(pool_config) do
        connection = Redis.new url: Attention.options[:redis_url]
        Redis::Namespace.new Attention.options[:namespace], redis: connection
      end
    end
  end
end
