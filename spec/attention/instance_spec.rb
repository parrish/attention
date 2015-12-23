require 'spec_helper'

module Attention
  RSpec.describe Instance do
    let(:redis){ Attention.publishing_redis.call }
    before(:each) do
      allow(Attention).to receive_message_chain('publishing_redis.call')
        .and_return redis
    end

    describe '#initialize' do
      before(:each) do
        redis.set 'attention_instances', 123
      end

      it 'should increment the instance count' do
        expect{
          subject
        }.to change{
          redis.get 'attention_instances'
        }.from('123').to '124'
      end

      it 'should set the id' do
        expect(subject.id).to eql '124'
      end
    end

    describe '#publish' do
      let(:instance_key){ 'attention_instance_1' }

      it 'should set the key to the ip' do
        subject.publish
        expect(redis.get(instance_key)).to match /\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/
      end

      it 'should set the key expiry' do
        subject.publish
        expect(redis.ttl(instance_key)).to be_within(1).of Attention.options[:ttl]
      end

      it 'should publish the new instance' do
        expect(redis).to receive(:publish) do |channel, payload|
          id, ip = payload.to_a.flatten
          expect(id).to eql '1'
          expect(ip).to match /\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/
        end

        subject.publish
      end
    end
  end
end
