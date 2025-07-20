class HealthController < ApplicationController
  # Health check endpoint for Docker containers and load balancers
  def show
    health_status = {
      status: 'ok',
      version: ENV['APP_VERSION'] || '1.0.0',
      timestamp: Time.current.iso8601,
      services: {
        database: database_status,
        redis: redis_status
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
    # Add Redis connection check when Redis is configured
    'not_configured'
  rescue
    'disconnected'
  end
end