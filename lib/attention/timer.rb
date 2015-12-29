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
        sleep @frequency
        lock.synchronize do
          callback.call
          @thread = nil
        end
        start
      end
    end

    def stop
      lock.synchronize do
        return unless thread
        thread.kill
        @thread = nil
      end
    end
  end
end
