# frozen_string_literal: true

class TenantResolver
  def initialize(app)
    @app = app
  end

  def call(env)
    request = ActionDispatch::Request.new(env)
    
    # Set the request environment for acts_as_tenant configuration
    $request_env = env
    
    # Resolve tenant from subdomain or header
    tenant = resolve_tenant(request)
    
    if tenant
      # Set the current tenant for the request
      ActsAsTenant.with_tenant(tenant) do
        @app.call(env)
      end
    else
      # Return 404 for invalid tenant
      render_tenant_not_found
    end
  ensure
    # Clean up the global variable
    $request_env = nil
  end

  private

  def resolve_tenant(request)
    # Try to resolve from subdomain first
    tenant = resolve_from_subdomain(request)
    
    # Fallback to header-based resolution (for API clients)
    tenant ||= resolve_from_header(request)
    
    # Ensure tenant is active
    tenant&.active? ? tenant : nil
  end

  def resolve_from_subdomain(request)
    host = request.host
    return nil unless host
    
    # Extract subdomain from host
    # Examples: 
    # - company1.autemix.com -> company1
    # - company1.localhost:3001 -> company1
    subdomain = extract_subdomain(host)
    return nil if subdomain.blank?
    
    Tenant.find_by_subdomain(subdomain)
  end

  def resolve_from_header(request)
    tenant_header = request.headers['X-Tenant-Subdomain']
    return nil if tenant_header.blank?
    
    Tenant.find_by_subdomain(tenant_header)
  end

  def extract_subdomain(host)
    # Remove port if present
    host = host.split(':').first
    
    # Split by dots and get the first part as subdomain
    parts = host.split('.')
    
    # For localhost development, treat the first part as subdomain
    # For production, ensure we have at least 2 parts (subdomain.domain.com)
    if host.include?('localhost') || Rails.env.development?
      # localhost or development: first part is subdomain
      parts.length > 1 ? parts.first : nil
    else
      # Production: need at least subdomain.domain.tld
      parts.length >= 3 ? parts.first : nil
    end
  end

  def render_tenant_not_found
    [
      404,
      { 'Content-Type' => 'application/json' },
      [{ error: 'Tenant not found', message: 'Invalid subdomain or tenant is inactive' }.to_json]
    ]
  end
end
