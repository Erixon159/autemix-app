# ActiveJob configuration for testing
RSpec.configure do |config|
  config.before(:suite) do
    ActiveJob::Base.queue_adapter = :test
  end

  config.before(:each) do
    ActiveJob::Base.queue_adapter.enqueued_jobs.clear
    ActiveJob::Base.queue_adapter.performed_jobs.clear
  end
end