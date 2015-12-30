require 'spec_helper'

module Attention
  RSpec.describe Publisher do
    describe '#publish' do
      let(:redis_double){ double :redis }

      before(:each) do
        allow(Attention).to receive_message_chain('redis.call')
          .and_return redis_double
      end

      it 'should publish the message' do
        expect(redis_double).to receive(:publish).with 'channel', '123'
        subject.publish 'channel', '123'
      end

      it 'yield redis if a block is given' do
        allow(redis_double).to receive :publish
        expect do |block|
          subject.publish 'channel', '123', &block
        end.to yield_with_args redis_double
      end
    end
  end
end
