# frozen_string_literal: true

class ApiKeyAuthentication
  def initialize(app)
    @app = app
  end

  def call(env)
    request = ActionDispatch::Request.new(env)
    
    # Only apply to API endpoints that require machine authentication
    if api_endpoint_requires_machine_auth?(request)
      api_key = extract_api_key(request)
      
      if api_key.blank?
        return unauthorized_response('API key required')
      end
      
      machine = VendingMachine.authenticate_with_api_key(api_key)
      
      if machine.nil?
        return unauthorized_response('Invalid API key')
      end
      
      # Set current machine and tenant in request environment
      env['current_machine'] = machine
      env['current_tenant'] = machine.tenant
      
      # Set tenant context for acts_as_tenant
      ActsAsTenant.current_tenant = machine.tenant
    end
    
    @app.call(env)
  end

  private

  def api_endpoint_requires_machine_auth?(request)
    # Check if this is a machine API endpoint
    request.path.start_with?('/api/v1/machines/') && 
    ['POST', 'PUT', 'PATCH'].include?(request.request_method)
  end

  def extract_api_key(request)
    # Try Authorization header first
    auth_header = request.headers['Authorization']
    if auth_header&.start_with?('Bearer ')
      return auth_header.sub('Bearer ', '')
    end
    
    # Try X-API-Key header
    request.headers['X-API-Key']
  end

  def unauthorized_response(message)
    [
      401,
      { 'Content-Type' => 'application/json' },
      [{ error: message, status: 401 }.to_json]
    ]
  end
end
