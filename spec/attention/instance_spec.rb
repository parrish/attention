require 'spec_helper'

module Attention
  RSpec.describe Instance do
    let(:redis){ Attention.redis.call }
    let(:timer_double){ double shutdown: true, execute: true }
    before(:each) do
      allow(Concurrent::TimerTask).to receive(:new)
        .and_return timer_double
      allow(Attention).to receive_message_chain('redis.call')
        .and_return redis
    end

    describe '#initialize' do
      before(:each) do
        redis.set 'instances', 123
      end

      it 'should increment the instance count' do
        expect{
          subject
        }.to change{
          redis.get 'instances'
        }.from('123').to '124'
      end

      it 'should set the id' do
        expect(subject.id).to eql '124'
      end
    end

    describe '#publish' do
      it 'should set the key to the ip' do
        subject.publish
        expect(redis.get('instance_1')).to match /(\d+\.){3}\d+/
      end

      it 'should set the key expiry' do
        subject.publish
        expect(redis.ttl('instance_1')).to be_within(1).of Attention.options[:ttl]
      end

      it 'should publish the new instance' do
        expect(redis).to receive(:publish) do |channel, payload|
          action, info = JSON.parse(payload).to_a.flatten
          expect(action).to eql 'added'
          expect(info['id']).to eql '1'
          expect(info['ip']).to match /(\d+\.){3}\d+/
        end

        subject.publish
      end

      it 'should start the heartbeat' do
        expect(subject).to receive(:heartbeat)
        subject.publish
      end
    end

    describe '#unpublish' do
      before(:each) do
        subject.instance_variable_set :@heartbeat, timer_double
      end

      it 'should delete the instance key' do
        expect(redis).to receive(:del).with 'instance_1'
        subject.unpublish
      end

      it 'should publish the removed instance' do
        expect(redis).to receive(:publish) do |channel, payload|
          action, info = JSON.parse(payload).to_a.flatten
          expect(action).to eql 'removed'
          expect(info['id']).to eql '1'
          expect(info['ip']).to match /(\d+\.){3}\d+/
        end

        subject.unpublish
      end

      it 'should stop the heartbeat' do
        expect(timer_double).to receive :shutdown
        subject.unpublish
      end

      it 'should clear the heartbeat' do
        expect{
          subject.unpublish
        }.to change{
          subject.instance_variable_get :@heartbeat
        }.to nil
      end
    end

    describe '#info' do
      context 'without overrides' do
        subject{ Instance.new.info }
        its([:id]){ is_expected.to eql '1' }
        its([:ip]){ is_expected.to match /(\d+\.){3}\d+/ }
        it{ is_expected.to_not have_key :port }
      end

      context 'with overrides' do
        subject{ Instance.new(ip: '1.2.3.4', port: 1234).info }
        its([:id]){ is_expected.to eql '1' }
        its([:ip]){ is_expected.to eql '1.2.3.4' }
        its([:port]){ is_expected.to eql 1234 }
      end
    end

    describe '#heartbeat' do
      before(:each) do
        allow(Concurrent::TimerTask).to receive(:new)
          .and_yield
          .and_return timer_double
      end

      it 'should start a timer' do
        expect(Concurrent::TimerTask).to receive(:new)
          .with(execution_interval: Attention.options[:ttl] - 5)
          .and_return timer_double
        subject.send :heartbeat
      end

      it 'should refresh the instance key' do
        expect(redis).to receive(:setex).with 'instance_1', Attention.options[:ttl], String
        subject.send :heartbeat
      end
    end
  end
end
