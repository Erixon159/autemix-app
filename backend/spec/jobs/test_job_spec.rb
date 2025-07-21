require 'rails_helper'

RSpec.describe TestJob, type: :job do
  describe '#perform' do
    it 'executes successfully with default message' do
      expect(Rails.logger).to receive(:info).with('TestJob executed: Hello from Sidekiq!')
      expect { TestJob.new.perform }.to output("TestJob executed: Hello from Sidekiq!\n").to_stdout
    end

    it 'executes successfully with custom message' do
      custom_message = 'Custom test message'
      expect(Rails.logger).to receive(:info).with("TestJob executed: #{custom_message}")
      expect { TestJob.new.perform(custom_message) }.to output("TestJob executed: #{custom_message}\n").to_stdout
    end

    it 'can be enqueued' do
      expect {
        TestJob.perform_later('Test message')
      }.to have_enqueued_job(TestJob).with('Test message')
    end
  end
end
