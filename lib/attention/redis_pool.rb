require 'redis'
require 'redis-namespace'
require 'connection_pool'

module Attention
  class RedisPool
    attr_reader :pool

    def self.instance
      @instance ||= new
      @pool ||= ->{ @instance.pool.with{ |redis| redis } }
    end

    private

    def initialize
      pool_config = {
        size: Attention.options[:pool_size],
        timeout: Attention.options[:timeout]
      }

      @pool = ConnectionPool.new(pool_config){ Connection.new }
    end
  end
end
