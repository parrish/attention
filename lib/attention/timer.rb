require 'thread'

module Attention
  class Timer
    attr_reader :frequency, :callback, :lock, :thread

    def initialize(frequency, &callback)
      @frequency = frequency
      @callback = callback
      @lock = Mutex.new
      start
    end

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

    def started?
      !!thread
    end

    def stop
      return if stopped?
      lock.synchronize do
        thread.kill
        @thread = nil
      end
    end

    def stopped?
      !started?
    end
  end
end
