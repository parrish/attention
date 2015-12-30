require 'redis'
require 'redis-namespace'
require 'connection_pool'

module Attention
  # A ConnectionPool of Redis connections used by {Publisher}s
  class RedisPool
    # @!visibility private
    attr_reader :pool

    # @return [RedisPool] A singleton instance of the ConnectionPool
    def self.instance
      @instance ||= new
      @pool ||= ->{ @instance.pool.with{ |redis| redis } }
    end

    private

    # As this is a singleton, +RedisPool.new+ is not public
    # @!visibility public
    # @api private
    def initialize
      pool_config = {
        size: Attention.options[:pool_size],
        timeout: Attention.options[:timeout]
      }

      @pool = ConnectionPool.new(pool_config){ Connection.new }
    end
  end
end
