require 'spec_helper'

module Attention
  RSpec.describe Subscriber do
    let(:callback){ ->(*data){ } }
    let(:message_double){ double :message }
    let(:hook){ double :hook }
    let(:redis){ double :redis }
    let(:payload){ 'data' }
    let(:subscriber){ Subscriber.new 'key', &callback }

    before(:each) do
      allow(Thread).to receive(:new).and_yield.and_return Thread.current
      allow(Connection).to receive(:new).and_return redis
      allow(redis).to receive(:subscribe).and_yield hook
      allow(hook).to receive(:message).and_yield 'channel', payload
    end

    describe '#initialize' do
      it 'should listen' do
        expect_any_instance_of(Subscriber).to receive(:subscribe) do |&block|
          expect(block).to eql callback
        end
        subscriber
      end
    end

    describe '#subscribe' do
      it 'subscribe to the key' do
        expect(redis).to receive :subscribe
        subscriber
      end

      it 'should listen to messages' do
        expect(hook).to receive :message
        subscriber
      end

      it 'should call the callback' do
        expect(callback).to receive(:call).with 'key', 'data'
        subscriber
      end

      context 'with a JSON payload' do
        let(:payload){ JSON.dump(foo: 'bar') }

        it 'should parse the JSON' do
          expect(callback).to receive(:call).with 'key', 'foo' => 'bar'
          subscriber
        end
      end

      context 'when already subscribed' do
        it 'should raise an error' do
          expect{
            subscriber.subscribe{ |*args| }
          }.to raise_error Subscriber::AlreadySubscribedError
        end
      end

      context 'with an unsubscribe message' do
        let(:payload){ 'unsubscribe' }

        before(:each) do
          allow(redis).to receive :unsubscribe
        end

        it 'should not call the callback' do
          expect(callback).to_not receive :call
          subscriber
        end

        it 'should unsubscribe from redis' do
          expect(redis).to receive :unsubscribe
          subscriber
        end
      end
    end

    describe '#unsubscribe' do
      let(:publisher){ double }

      before(:each) do
        allow(Publisher).to receive(:new).and_return publisher
        allow(publisher).to receive :publish
      end

      it 'should publish an unsubscribe message' do
        expect(publisher).to receive(:publish).with 'unsubscribe'
        subscriber.unsubscribe
      end

      it 'should clear the thread' do
        expect{
          subscriber.unsubscribe
        }.to change {
          subscriber.instance_variable_get '@thread'
        }.to nil
      end
    end
  end
end
