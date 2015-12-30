require 'redis'
require 'redis-namespace'

module Attention
  # Provides a namespaced Redis connection
  module Connection
    # Creates a Redis connection
    # @return [Redis] A namespaced Redis connection with configuration
    #   from Attention.options
    def self.new
      connection = Redis.new url: Attention.options[:redis_url],
          connect_timeout: Attention.options[:timeout],
          timeout: Attention.options[:timeout]

      Redis::Namespace.new Attention.options[:namespace], redis: connection
    end
  end
end
