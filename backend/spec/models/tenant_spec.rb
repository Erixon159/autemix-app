require 'rails_helper'

RSpec.describe Tenant, type: :model do
  describe 'validations' do
    subject { build(:tenant) }
    
    it { should validate_presence_of(:name) }
    it { should validate_length_of(:name).is_at_least(2).is_at_most(100) }
    
    it { should validate_presence_of(:subdomain) }
    it { should validate_uniqueness_of(:subdomain).case_insensitive }
    it { should validate_length_of(:subdomain).is_at_least(2).is_at_most(63) }
    
    describe 'subdomain format validation' do
      it 'allows valid subdomains' do
        valid_subdomains = %w[company1 test-company my-app-123 abc]
        valid_subdomains.each do |subdomain|
          tenant = build(:tenant, subdomain: subdomain)
          expect(tenant).to be_valid, "#{subdomain} should be valid"
        end
      end
      
      it 'rejects invalid subdomains' do
        invalid_subdomains = %w[-invalid invalid- -invalid- invalid..com invalid_name]
        invalid_subdomains.each do |subdomain|
          tenant = build(:tenant, subdomain: subdomain)
          expect(tenant).not_to be_valid, "#{subdomain} should be invalid"
        end
      end
      
      it 'rejects reserved subdomains' do
        reserved_subdomains = %w[www api admin app mail ftp localhost]
        reserved_subdomains.each do |subdomain|
          tenant = build(:tenant, subdomain: subdomain)
          expect(tenant).not_to be_valid, "#{subdomain} should be reserved"
          expect(tenant.errors[:subdomain]).to include('is reserved')
        end
      end
    end
  end
  
  describe 'scopes' do
    let!(:active_tenant) { create(:tenant, active: true) }
    let!(:inactive_tenant) { create(:tenant, active: false) }
    
    describe '.active' do
      it 'returns only active tenants' do
        expect(Tenant.active).to include(active_tenant)
        expect(Tenant.active).not_to include(inactive_tenant)
      end
    end
    
    describe '.inactive' do
      it 'returns only inactive tenants' do
        expect(Tenant.inactive).to include(inactive_tenant)
        expect(Tenant.inactive).not_to include(active_tenant)
      end
    end
  end
  
  describe 'callbacks' do
    describe 'normalize_subdomain' do
      it 'normalizes subdomain to lowercase' do
        tenant = create(:tenant, subdomain: 'COMPANY')
        expect(tenant.subdomain).to eq('company')
      end
      
      it 'strips whitespace from subdomain' do
        tenant = create(:tenant, subdomain: '  company  ')
        expect(tenant.subdomain).to eq('company')
      end
    end
    
    describe 'set_default_active_status' do
      it 'sets active to true by default' do
        tenant = create(:tenant, active: nil)
        expect(tenant.active).to be true
      end
    end
  end
  
  describe 'class methods' do
    let!(:tenant) { create(:tenant, subdomain: 'testcompany') }
    
    describe '.find_by_subdomain' do
      it 'finds tenant by subdomain' do
        expect(Tenant.find_by_subdomain('testcompany')).to eq(tenant)
      end
      
      it 'is case insensitive' do
        expect(Tenant.find_by_subdomain('TESTCOMPANY')).to eq(tenant)
      end
      
      it 'strips whitespace' do
        expect(Tenant.find_by_subdomain('  testcompany  ')).to eq(tenant)
      end
      
      it 'returns nil for blank subdomain' do
        expect(Tenant.find_by_subdomain('')).to be_nil
        expect(Tenant.find_by_subdomain(nil)).to be_nil
      end
    end
    
    describe '.current' do
      it 'returns the current tenant from ActsAsTenant' do
        ActsAsTenant.with_tenant(tenant) do
          expect(Tenant.current).to eq(tenant)
        end
      end
    end
  end
  
  describe 'instance methods' do
    let(:tenant) { create(:tenant, subdomain: 'testcompany', name: 'Test Company') }
    
    describe '#to_param' do
      it 'returns the subdomain' do
        expect(tenant.to_param).to eq('testcompany')
      end
    end
    
    describe '#full_domain' do
      it 'returns the full domain with default base' do
        expect(tenant.full_domain).to eq('testcompany.autemix.com')
      end
      
      it 'returns the full domain with custom base' do
        expect(tenant.full_domain('example.com')).to eq('testcompany.example.com')
      end
    end
    
    describe '#activate!' do
      it 'activates an inactive tenant' do
        tenant.update!(active: false)
        tenant.activate!
        expect(tenant.reload.active).to be true
      end
    end
    
    describe '#deactivate!' do
      it 'deactivates an active tenant' do
        tenant.deactivate!
        expect(tenant.reload.active).to be false
      end
    end
  end
end
