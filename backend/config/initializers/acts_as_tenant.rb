# ActsAsTenant configuration for Autemix Admin Platform

ActsAsTenant.configure do |config|
  # Require tenant to be set for all requests, but allow exceptions for specific paths
  config.require_tenant = lambda do
    # Skip tenant requirement for health checks, Sidekiq web interface, and Rails internal routes
    if defined?($request_env) && $request_env.present?
      request_path = $request_env["REQUEST_PATH"] || ""
      return false if request_path.start_with?("/health", "/up", "/sidekiq", "/rails/")
    end
    
    # Require tenant for all other requests
    true
  end
  
  # Customize the query for loading the tenant in background jobs
  config.job_scope = -> { where(active: true) }
end

# Development console helper - set a default tenant for easier testing
SET_TENANT_PROC = lambda do
  if defined?(Rails::Console)
    first_tenant = Tenant.active.first
    if first_tenant
      puts "> ActsAsTenant.current_tenant = #{first_tenant.name} (#{first_tenant.subdomain})"
      ActsAsTenant.current_tenant = first_tenant
    else
      puts "> No active tenants found. Create one with: Tenant.create!(name: 'Test Company', subdomain: 'test')"
    end
  end
end

Rails.application.configure do
  if Rails.env.development?
    # Set the tenant to the first active tenant in development on load
    config.after_initialize do
      SET_TENANT_PROC.call
    end
    
    # Reset the tenant after calling 'reload!' in the console
    ActiveSupport::Reloader.to_complete do
      SET_TENANT_PROC.call
    end
  end
end
