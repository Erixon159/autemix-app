# Sidekiq configuration for Autemix Admin Platform

require 'sidekiq'
require 'sidekiq/web'

# Configure Sidekiq (Sidekiq 7+ doesn't support namespaces)
Sidekiq.configure_server do |config|
  config.redis = { 
    url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0')
  }
  
  # Configure concurrency
  config.concurrency = ENV.fetch('SIDEKIQ_CONCURRENCY', 5).to_i
end

Sidekiq.configure_client do |config|
  config.redis = { 
    url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0')
  }
end

# Configure Active Job to use Sidekiq
Rails.application.configure do
  config.active_job.queue_adapter = :sidekiq
end
