require 'spec_helper'

RSpec.describe Attention do
  describe '.options' do
    subject{ Attention.options }
    its([:namespace]){ is_expected.to eql 'attention' }
    its([:ttl]){ is_expected.to eql 60 }
    its([:redis_url]){ is_expected.to eql 'redis://localhost:6379/0' }
    its([:pool_size]){ is_expected.to eql 5 }
    its([:timeout]){ is_expected.to eql 5 }
  end

  describe '.redis' do
    subject{ Attention.redis }
    it{ is_expected.to be_a Proc }
    its(:call){ is_expected.to be_a Redis::Namespace }
  end

  describe '.announce' do
    it 'should publish the instance' do
      expect(Attention::Instance).to receive_message_chain 'new.publish'
      Attention.announce
    end
  end

  describe '.instances' do
    subject{ Attention.instances }
    before(:each) do
      3.times{ Attention::Instance.new.publish }
    end

    it{ is_expected.to be_a Hash }
    its(:length){ is_expected.to eql 3 }
    its('keys.first'){ is_expected.to match /instance_\d/ }
    its('values.first'){ is_expected.to match /(\d+\.){3}\d+/}
  end
end
