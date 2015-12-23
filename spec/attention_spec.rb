require 'spec_helper'

RSpec.describe Attention do
  RSpec.shared_examples_for 'a redis connection' do |type:|
    describe ".#{ type }_redis" do
      subject{ Attention.send "#{ type }_redis" }
      it{ is_expected.to be_a Proc }
      its(:call){ is_expected.to be_a Redis::Namespace }
    end
  end

  it_behaves_like 'a redis connection', type: :subscribing
  it_behaves_like 'a redis connection', type: :publishing

  describe '.options' do
    subject{ Attention.options }
    its([:namespace]){ is_expected.to eql 'attention' }
    its([:ttl]){ is_expected.to eql 60 }
    its([:redis_url]){ is_expected.to eql 'redis://localhost:6379/0' }
    its([:pool_size]){ is_expected.to eql 5 }
    its([:timeout]){ is_expected.to eql 5 }
  end
end
