require 'thread'
require 'json'

module Attention
  class Subscriber
    attr_reader :key

    def initialize(key, &callback)
      @key = key
      listen_to key, &callback
    end

    def listen_to(key, &callback)
      @thread = Thread.new do
        Attention.subscribing_redis.call.subscribe(key) do |on|
          on.message do |channel, payload|
            data = JSON.parse(payload) rescue payload
            callback.call key, data
          end
        end
      end
    end
  end
end
