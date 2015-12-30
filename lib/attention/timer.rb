require 'thread'

module Attention
  # Periodic asynchronous code execution
  class Timer
    attr_reader :frequency

    # @!visibility private
    attr_reader :callback, :lock, :thread

    # Creates and {#start}s the timer
    # @param frequency [Numeric] How often to execute
    # @yield The code to be executed
    def initialize(frequency, &callback)
      @frequency = frequency
      @callback = callback
      @lock = Mutex.new
      start
    end

    # Starts the timer
    def start
      @thread ||= Thread.new do
        loop do
          sleep @frequency
          lock.synchronize do
            callback.call
          end
        end
      end
    end

    # @return [Boolean] True if the timer is started
    def started?
      !!thread
    end

    # Stops the timer if it's started
    def stop
      return if stopped?
      lock.synchronize do
        thread.kill
        @thread = nil
      end
    end

    # @return [Boolean] True if the timer is stopped
    def stopped?
      !started?
    end
  end
end
