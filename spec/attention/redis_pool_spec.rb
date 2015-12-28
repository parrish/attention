require 'spec_helper'

module Attention
  RSpec.describe RedisPool do
    describe '.instance' do
      subject{ Attention::RedisPool.instance }
      before(:each) do
        Attention::RedisPool.instance_variable_set :@instance, nil
        Attention::RedisPool.instance_variable_set :@redis_pool, nil
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
            url: Attention.options[:redis_url],
            connect_timeout: Attention.options[:timeout],
            timeout: Attention.options[:timeout]
          }).and_call_original

        subject.call
      end

      it 'should return a singleton' do
        first_call = Attention::RedisPool.instance.object_id
        second_call = Attention::RedisPool.instance.object_id
        expect(first_call).to eql second_call
      end
    end
  end
end
