require 'rails_helper'

RSpec.describe TenantService, type: :service do
  let!(:active_tenant) { create(:tenant, name: 'Active Company', subdomain: 'active') }
  let!(:inactive_tenant) { create(:tenant, :inactive, name: 'Inactive Company', subdomain: 'inactive') }
  
  describe '.current' do
    it 'returns the current tenant' do
      ActsAsTenant.with_tenant(active_tenant) do
        expect(TenantService.current).to eq(active_tenant)
      end
    end
    
    it 'returns nil when no tenant is set' do
      expect(TenantService.current).to be_nil
    end
  end
  
  describe '.with_tenant' do
    it 'switches to a tenant by object' do
      TenantService.with_tenant(active_tenant) do
        expect(TenantService.current).to eq(active_tenant)
      end
    end
    
    it 'switches to a tenant by subdomain string' do
      TenantService.with_tenant('active') do
        expect(TenantService.current).to eq(active_tenant)
      end
    end
    
    it 'raises error for non-existent tenant' do
      expect {
        TenantService.with_tenant('nonexistent') { }
      }.to raise_error(ArgumentError, 'Tenant not found')
    end
    
    it 'raises error for inactive tenant' do
      expect {
        TenantService.with_tenant(inactive_tenant) { }
      }.to raise_error(ArgumentError, 'Tenant is not active')
    end
  end
  
  describe '.with_subdomain' do
    it 'switches to a tenant by subdomain' do
      TenantService.with_subdomain('active') do
        expect(TenantService.current).to eq(active_tenant)
      end
    end
    
    it 'raises error for non-existent subdomain' do
      expect {
        TenantService.with_subdomain('nonexistent') { }
      }.to raise_error(ArgumentError, 'Tenant not found')
    end
  end
  
  describe '.in_tenant_context?' do
    it 'returns true when in tenant context' do
      ActsAsTenant.with_tenant(active_tenant) do
        expect(TenantService.in_tenant_context?).to be true
      end
    end
    
    it 'returns false when not in tenant context' do
      expect(TenantService.in_tenant_context?).to be false
    end
  end
  
  describe '.current_subdomain' do
    it 'returns current tenant subdomain' do
      ActsAsTenant.with_tenant(active_tenant) do
        expect(TenantService.current_subdomain).to eq('active')
      end
    end
    
    it 'returns nil when no tenant is set' do
      expect(TenantService.current_subdomain).to be_nil
    end
  end
  
  describe '.create_tenant' do
    it 'creates a new tenant with valid attributes' do
      tenant = TenantService.create_tenant(name: 'New Company', subdomain: 'newcompany')
      
      expect(tenant).to be_persisted
      expect(tenant.name).to eq('New Company')
      expect(tenant.subdomain).to eq('newcompany')
      expect(tenant.active).to be true
    end
    
    it 'returns invalid tenant with errors for invalid attributes' do
      tenant = TenantService.create_tenant(name: '', subdomain: 'admin')
      
      expect(tenant).not_to be_persisted
      expect(tenant.errors).to be_present
    end
  end
  
  describe '.deactivate_tenant' do
    it 'deactivates a tenant by object' do
      result = TenantService.deactivate_tenant(active_tenant)
      
      expect(result).to be true
      expect(active_tenant.reload.active).to be false
    end
    
    it 'deactivates a tenant by subdomain' do
      result = TenantService.deactivate_tenant('active')
      
      expect(result).to be true
      expect(active_tenant.reload.active).to be false
    end
    
    it 'returns false for non-existent tenant' do
      result = TenantService.deactivate_tenant('nonexistent')
      expect(result).to be false
    end
  end
  
  describe '.activate_tenant' do
    it 'activates a tenant by object' do
      result = TenantService.activate_tenant(inactive_tenant)
      
      expect(result).to be true
      expect(inactive_tenant.reload.active).to be true
    end
    
    it 'activates a tenant by subdomain' do
      result = TenantService.activate_tenant('inactive')
      
      expect(result).to be true
      expect(inactive_tenant.reload.active).to be true
    end
    
    it 'returns false for non-existent tenant' do
      result = TenantService.activate_tenant('nonexistent')
      expect(result).to be false
    end
  end
end