require 'thread'
require 'json'
require 'attention/connection'
require 'attention/publisher'

module Attention
  # Uses Redis pub/sub to asynchronously respond to events
  # 
  # Each Subscriber uses a Redis connection to listen to a channel for events.
  class Subscriber
    # The channel subscribed to
    attr_reader :channel

    # @!visibility private
    attr_reader :redis

    # Raised when attempting to subscribe multiple times
    # 
    # Rather than attempting to reuse a subscriber,
    # unsubscribe and create a new one
    class AlreadySubscribedError < StandardError; end

    # Creates a subscription to the given channel
    # @param channel [String] The channel to listen to
    # @yield The code to execute on a published event
    # @yieldparam channel [String] The channel the subscriber is listening to
    # @yieldparam data [Object] The event published on the channel
    def initialize(channel, &callback)
      @channel = channel
      @redis = Connection.new
      subscribe &callback
    end

    # Sets up the Redis pub/sub subscription
    # @yield The code to execute on a published event
    # @raise [AlreadySubscribedError] If the subscriber is already subscribed
    def subscribe(&callback)
      raise AlreadySubscribedError.new if @thread
      @thread = Thread.new do
        redis.subscribe(channel) do |on|
          on.message do |channel, payload|
            data = JSON.parse(payload) rescue payload
            if data == 'unsubscribe'
              redis.unsubscribe
            else
              callback.call channel, data
            end
          end
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
      publisher.publish channel, 'unsubscribe'
      @thread.kill
      @thread = nil
    end
  end
end
