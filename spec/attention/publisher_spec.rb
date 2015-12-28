require 'spec_helper'

module Attention
  RSpec.describe Publisher do
    subject{ Publisher.new 'publish_key' }

    describe '#initialize' do
      its(:key){ is_expected.to eql 'publish_key' }
    end

    describe '#publish' do
      let(:redis_double){ double :redis }

      before(:each) do
        allow(Attention).to receive_message_chain('redis.call')
          .and_return redis_double
      end

      it 'should publish the message' do
        expect(redis_double).to receive(:publish).with 'publish_key', '123'
        subject.publish '123'
      end

      it 'yield redis if a block is given' do
        allow(redis_double).to receive :publish
        expect do |block|
          subject.publish '123', &block
        end.to yield_with_args redis_double
      end
    end
  end
end
