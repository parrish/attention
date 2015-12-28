require 'thread'
require 'json'
require 'attention/connection'

module Attention
  class Subscriber
    attr_reader :key, :redis

    class AlreadySubscribedError < StandardError; end

    def initialize(key, &callback)
      @key = key
      @redis = Connection.new
      subscribe &callback
    end

    def subscribe(&callback)
      raise AlreadySubscribedError.new if @thread
      @thread = Thread.new do
        redis.subscribe(key) do |on|
          on.message do |channel, payload|
            data = JSON.parse(payload) rescue payload
            callback.call key, data
          end
        end
      end
    end
  end
end
