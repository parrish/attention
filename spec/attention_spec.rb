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

  describe '.activate' do
    it 'should publish the instance' do
      expect_any_instance_of(Attention::Instance).to receive :publish
      Attention.activate
    end

    context 'with overrides' do
      before(:each) do
        Attention.activate ip: '1.2.3.4', port: 9876
      end

      subject{ Attention.instance.info }
      its([:ip]){ is_expected.to eql '1.2.3.4' }
      its([:port]){ is_expected.to eql 9876 }
    end
  end

  describe '.deactivate' do
    before(:each){ Attention.activate }

    it 'should unpublish the instance' do
      expect(Attention.instance).to receive :unpublish
      Attention.deactivate
    end
  end

  describe '.instances' do
    subject{ Attention.instances }
    before(:each) do
      3.times{ Attention::Instance.new.publish }
    end

    it{ is_expected.to be_an Array }
    its(:length){ is_expected.to eql 3 }
    its('first.keys'){ is_expected.to match_array %w(id ip) }
  end
end
