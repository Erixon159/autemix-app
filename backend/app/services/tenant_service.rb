class TenantService
  class << self
    # Get the current tenant
    def current
      ActsAsTenant.current_tenant
    end
    
    # Switch to a specific tenant for the duration of a block
    def with_tenant(tenant, &block)
      if tenant.is_a?(String)
        tenant = Tenant.find_by_subdomain(tenant)
      end
      
      raise ArgumentError, "Tenant not found" unless tenant
      raise ArgumentError, "Tenant is not active" unless tenant.active?
      
      ActsAsTenant.with_tenant(tenant, &block)
    end
    
    # Switch tenant by subdomain
    def with_subdomain(subdomain, &block)
      tenant = Tenant.find_by_subdomain(subdomain)
      with_tenant(tenant, &block)
    end
    
    # Check if we're currently in a tenant context
    def in_tenant_context?
      ActsAsTenant.current_tenant.present?
    end
    
    # Get current tenant's subdomain
    def current_subdomain
      current&.subdomain
    end
    
    # Create a new tenant with proper setup
    def create_tenant(name:, subdomain:, **attributes)
      tenant = Tenant.new(
        name: name,
        subdomain: subdomain,
        **attributes
      )
      
      if tenant.save
        # Perform any additional tenant setup here
        setup_tenant_data(tenant)
        tenant
      else
        tenant
      end
    end
    
    # Set up initial data for a new tenant
    def setup_tenant_data(tenant)
      with_tenant(tenant) do
        # This is where we'll add initial data setup for new tenants
        # For now, just log the setup
        Rails.logger.info "Setting up initial data for tenant: #{tenant.name} (#{tenant.subdomain})"
      end
    end
    
    # Deactivate a tenant and clean up
    def deactivate_tenant(tenant)
      tenant = Tenant.find_by_subdomain(tenant) if tenant.is_a?(String)
      return false unless tenant
      
      tenant.deactivate!
      Rails.logger.info "Deactivated tenant: #{tenant.name} (#{tenant.subdomain})"
      true
    end
    
    # Reactivate a tenant
    def activate_tenant(tenant)
      tenant = Tenant.find_by_subdomain(tenant) if tenant.is_a?(String)
      return false unless tenant
      
      tenant.activate!
      Rails.logger.info "Activated tenant: #{tenant.name} (#{tenant.subdomain})"
      true
    end
  end
end
