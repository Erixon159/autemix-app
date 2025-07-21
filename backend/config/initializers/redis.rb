# Redis configuration for Autemix Admin Platform

# Redis connection configuration
redis_url = ENV.fetch('REDIS_URL', 'redis://localhost:6379/0')

# Configure Redis connection
$redis = Redis.new(url: redis_url)

# Configure Rails cache to use Redis
Rails.application.configure do
  config.cache_store = :redis_cache_store, {
    url: redis_url,
    namespace: 'autemix_admin_cache',
    expires_in: 1.hour
  }
end

# Configure Sidekiq to use Redis (Sidekiq 7+ doesn't support namespaces)
Sidekiq.configure_server do |config|
  config.redis = { url: redis_url }
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url }
end
