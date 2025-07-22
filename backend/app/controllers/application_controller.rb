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
end
