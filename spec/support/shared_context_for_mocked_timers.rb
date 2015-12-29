require 'spec_helper'

module Attention
  RSpec.shared_context 'mocked timers' do
    let(:callback){ ->{ } }
    let(:frequency){ 5 }
    let(:timer){ Timer.new frequency, &callback }
    subject{ timer }

    before(:each) do
      Timer.class_eval do
        alias_method :actual_start, :start
        define_method(:start){ }
      end

      allow(timer).to receive :sleep
      allow(Thread).to receive(:new).and_yield
    end

    after(:each) do
      Timer.class_eval do
        alias_method :start, :actual_start
        undef :actual_start
      end
    end
  end
end
