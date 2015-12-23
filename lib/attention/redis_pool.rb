require 'redis'
require 'redis-namespace'
require 'connection_pool'

module Attention
  class RedisPool
    attr_reader :pool

    def self.instance
      @instance ||= new
      @redis_pool ||= ->{ @instance.pool.with{ |redis| redis } }
    end

    private
    def initialize
      pool_config = { size: Attention.options[:pool_size], timeout: Attention.options[:timeout] }

      @pool = ConnectionPool.new(pool_config) do
        connection = Redis.new url: Attention.options[:redis_url]
        Redis::Namespace.new Attention.options[:namespace], redis: connection
      end
    end
  end
end
