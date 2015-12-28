require 'spec_helper'

module Attention
  RSpec.describe RedisPool do
    RSpec.shared_examples_for 'a redis pool' do |type:|
      let(:redis_url){ Attention.options[:redis_url] }

      let(:instance_variable){ :"@#{ type }_instance" }
      let(:instance){ RedisPool.send :"#{ type }_instance" }

      subject{ instance }

      before(:each) do
        RedisPool.instance_variable_set instance_variable, nil
      end

      it{ is_expected.to be_a Proc }
      its(:call){ is_expected.to be_a Redis::Namespace }

      it 'should initialize a connection pool' do
        pool_options = {
          size: Attention.options[:pool_size],
          timeout: Attention.options[:timeout]
        }

        expect(ConnectionPool).to receive(:new).with pool_options
        subject
      end

      it 'should initialize Redis' do
        expect(Redis).to receive(:new)
          .with({
            url: redis_url,
            connect_timeout: Attention.options[:timeout],
            timeout: Attention.options[:timeout]
          }).and_call_original

        subject.call
      end

      it 'should return a singleton' do
        first_call = RedisPool.instance_variable_get(instance_variable).object_id
        second_call = RedisPool.instance_variable_get(instance_variable).object_id
        expect(first_call).to eql second_call
      end
    end

    describe '.subscribing_instance' do
      it_behaves_like 'a redis pool', type: 'subscribing'
    end

    describe '.publishing_instance' do
      it_behaves_like 'a redis pool', type: 'publishing'
    end
  end
end
