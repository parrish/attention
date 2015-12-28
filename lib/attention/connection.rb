require 'redis'
require 'redis-namespace'

module Attention
  module Connection
    def self.new
      connection = Redis.new url: Attention.options[:redis_url],
          connect_timeout: Attention.options[:timeout],
          timeout: Attention.options[:timeout]

      Redis::Namespace.new Attention.options[:namespace], redis: connection
    end
  end
end
