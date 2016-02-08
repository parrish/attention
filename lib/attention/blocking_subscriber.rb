require 'json'
require 'attention/connection'
require 'attention/publisher'

module Attention
  # Uses Redis pub/sub to synchronously respond to events
  # 
  # Each Subscriber uses a Redis connection to listen to a channel for events.
  class BlockingSubscriber
    # The channel subscribed to
    attr_reader :channel

    # @!visibility private
    attr_reader :redis

    # Creates a subscription to the given channel
    # @param channel [String] The channel to listen to
    # @yield The code to execute on a published event
    # @yieldparam channel [String] The channel the subscriber is listening to
    # @yieldparam data [Object] The event published on the channel
    # @yieldparam subscriber [BlockingSubscriber] This instance
    def initialize(channel, &callback)
      @channel = channel
      @redis = Connection.new
      subscribe &callback
    end

    # Sets up the Redis pub/sub subscription
    # @yield The code to execute on a published event
    def subscribe(&callback)
      redis.subscribe(channel) do |on|
        on.message do |channel, payload|
          data = JSON.parse(payload) rescue payload
          callback.call channel, data, self
        end
      end
    end

    # The {Publisher} used to send the unsubscribe message
    # @api private
    def publisher
      @publisher ||= Publisher.new
    end

    # Unsubscribes from the channel
    def unsubscribe
      redis.unsubscribe
    end
  end
end
