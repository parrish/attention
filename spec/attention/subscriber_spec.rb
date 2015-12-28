require 'spec_helper'

module Attention
  RSpec.describe Subscriber do
    let(:callback){ ->(*data){ } }

    describe '#initialize' do
      it 'should listen' do
        expect_any_instance_of(Subscriber).to receive(:subscribe) do |&block|
          expect(block).to eql callback
        end
        Subscriber.new 'key', &callback
      end
    end

    describe '#subscribe' do
      let(:message_double){ double :message }
      let(:hook){ double :hook }
      let(:redis){ double :redis }
      let(:payload){ 'data' }

      before(:each) do
        allow(Thread).to receive(:new).and_yield
        allow(Attention).to receive_message_chain('subscribing_redis.call').and_return redis
        allow(redis).to receive(:subscribe).and_yield hook
        allow(hook).to receive(:message).and_yield 'channel', payload
      end

      it 'subscribe to the key' do
        expect(redis).to receive :subscribe
        Subscriber.new 'key', &callback
      end

      it 'should listen to messages' do
        expect(hook).to receive :message
        Subscriber.new 'key', &callback
      end

      it 'should call the callback' do
        expect(callback).to receive(:call).with 'key', 'data'
        Subscriber.new 'key', &callback
      end

      context 'with a JSON payload' do
        let(:payload){ JSON.dump(foo: 'bar') }

        it 'should parse the JSON' do
          expect(callback).to receive(:call).with 'key', 'foo' => 'bar'
          Subscriber.new 'key', &callback
        end
      end
    end
  end
end
