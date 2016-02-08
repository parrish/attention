require 'spec_helper'

module Attention
  RSpec.describe BlockingSubscriber do
    let(:callback){ ->(*data){ } }
    let(:message_double){ double :message }
    let(:hook){ double :hook }
    let(:redis){ double :redis }
    let(:payload){ 'data' }
    let(:subscriber){ BlockingSubscriber.new 'channel', &callback }

    before(:each) do
      allow(Connection).to receive(:new).and_return redis
      allow(redis).to receive(:subscribe).and_yield hook
      allow(hook).to receive(:message).and_yield 'channel', payload
    end

    describe '#initialize' do
      it 'should listen' do
        expect_any_instance_of(BlockingSubscriber).to receive(:subscribe) do |&block|
          expect(block).to eql callback
        end
        subscriber
      end
    end

    describe '#subscribe' do
      it 'subscribe to the channel' do
        expect(redis).to receive :subscribe
        subscriber
      end

      it 'should listen to messages' do
        expect(hook).to receive :message
        subscriber
      end

      it 'should call the callback' do
        expect(callback).to receive(:call).with 'channel', 'data', an_instance_of(BlockingSubscriber)
        subscriber
      end

      context 'with a JSON payload' do
        let(:payload){ JSON.dump(foo: 'bar') }

        it 'should parse the JSON' do
          expect(callback).to receive(:call).with 'channel', { 'foo' => 'bar' }, an_instance_of(BlockingSubscriber)
          subscriber
        end
      end
    end

    describe '#unsubscribe' do
      it 'should unsubscribe from redis' do
        expect(redis).to receive :unsubscribe
        subscriber.unsubscribe
      end
    end
  end
end
