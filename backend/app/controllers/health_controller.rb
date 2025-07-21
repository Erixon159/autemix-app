class HealthController < ApplicationController
  # Health check endpoint for Docker containers and load balancers
  def show
    health_status = {
      status: 'ok',
      version: ENV['APP_VERSION'] || '1.0.0',
      timestamp: Time.current.iso8601,
      services: {
        database: database_status,
        redis: redis_status,
        sidekiq: sidekiq_status
      }
    }

    render json: health_status, status: :ok
  rescue => e
    render json: {
      status: 'error',
      version: ENV['APP_VERSION'] || '1.0.0',
      timestamp: Time.current.iso8601,
      error: e.message
    }, status: :service_unavailable
  end

  private

  def database_status
    ActiveRecord::Base.connection.execute('SELECT 1')
    'connected'
  rescue
    'disconnected'
  end

  def redis_status
    $redis.ping == 'PONG' ? 'connected' : 'disconnected'
  rescue => e
    Rails.logger.error "Redis health check failed: #{e.message}"
    'disconnected'
  end

  def sidekiq_status
    # Check if Sidekiq can connect to Redis and get stats
    stats = Sidekiq::Stats.new
    workers = Sidekiq::Workers.new
    
    {
      status: 'running',
      processed: stats.processed,
      failed: stats.failed,
      busy: stats.workers_size,
      enqueued: stats.enqueued,
      workers: workers.size
    }
  rescue => e
    Rails.logger.error "Sidekiq health check failed: #{e.message}"
    {
      status: 'disconnected',
      error: e.message
    }
  end
end
