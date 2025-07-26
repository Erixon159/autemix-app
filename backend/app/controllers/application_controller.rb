class ApplicationController < ActionController::API
  # Tenant context helpers
  before_action :ensure_tenant_context
  
  protected
  
  def current_tenant
    TenantService.current
  end
  
  def ensure_tenant_context
    unless TenantService.in_tenant_context?
      render json: { error: 'Tenant context required' }, status: :bad_request
    end
  end
  
  # Skip tenant requirement for specific actions (like health checks)
  def skip_tenant_requirement
    skip_before_action :ensure_tenant_context
  end
  
  # Authentication helpers (to be implemented with custom JWT system)
  def current_user
    @current_user
  end
  
  def authenticate_request!
    if request.headers['X-API-Key']
      # API key authentication (from vending machines) - preserve existing functionality
      authenticate_vending_machine!
    else
      # Custom JWT authentication will be implemented here
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end
  
  private
  
  def authenticate_vending_machine!
    api_key = request.headers['X-API-Key']
    return false if api_key.blank?
    
    machine = VendingMachine.authenticate_with_api_key(api_key)
    return false if machine.nil?
    
    # Set current machine and tenant context
    @current_machine = machine
    ActsAsTenant.current_tenant = machine.tenant
    true
  end
  
  def current_machine
    @current_machine
  end
end
