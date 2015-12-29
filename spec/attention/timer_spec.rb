require 'spec_helper'

module Attention
  RSpec.describe Timer do
    include_context 'mocked timers'

    describe '#initialize' do
      its(:frequency){ is_expected.to eql frequency }
      its(:callback){ is_expected.to eql callback }
      its(:lock){ is_expected.to be_a Mutex }
    end

    describe '#start' do
      it 'should store the thread' do
        allow(Thread).to receive(:new).and_call_original

        expect{
          timer.actual_start
        }.to change{
          timer.thread
        }.to a_kind_of Thread
      end

      it 'should sleep' do
        expect(timer).to receive(:sleep).with frequency
        timer.actual_start
      end

      it 'should use the mutex' do
        expect(timer.lock).to receive(:synchronize)
        timer.actual_start
      end

      it 'should call the callback' do
        expect(callback).to receive :call
        timer.actual_start
      end

      it 'should clear the timer thread' do
        timer.actual_start
        expect(timer.thread).to be_nil
      end

      it 'should restart the timer' do
        expect(timer).to receive :start
        timer.actual_start
      end
    end

    describe '#stop' do
      let(:thread_double){ double kill: true }

      before(:each) do
        timer.instance_variable_set :@thread, thread_double
      end

      it 'should kill the thread' do
        expect(thread_double).to receive :kill
        timer.stop
      end

      it 'should forget the thread' do
        expect{
          timer.stop
        }.to change{
          timer.thread
        }.from(thread_double).to nil
      end
    end
  end
end
