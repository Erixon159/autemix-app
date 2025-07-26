require 'rails_helper'

RSpec.describe VendingMachine, type: :model do
  let(:tenant) { create(:tenant) }
  
  around(:each) do |example|
    ActsAsTenant.with_tenant(tenant) do
      example.run
    end
  end
  
  describe 'validations' do
    subject { build(:vending_machine, tenant: tenant) }
    
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:location) }
    it { should validate_presence_of(:api_key_digest) }
    it { should validate_length_of(:name).is_at_most(100) }
    it { should validate_length_of(:location).is_at_most(255) }
    it { should validate_uniqueness_of(:api_key_digest) }
  end
  
  describe '#generate_api_key!' do
    it 'generates and stores an encrypted API key' do
      machine = build(:vending_machine, tenant: tenant, api_key_digest: nil)
      api_key = machine.generate_api_key!
      
      expect(api_key).to be_present
      expect(api_key.length).to eq(64) # 32 bytes hex = 64 characters
      expect(machine.api_key_digest).to be_present
      expect(machine.api_key_digest).not_to eq(api_key)
    end
  end
  
  describe '.authenticate_with_api_key' do
    let!(:machine) { create(:vending_machine, tenant: tenant) }
    let(:api_key) { SecureRandom.hex(32) }
    
    before do
      machine.update!(api_key_digest: Rails.application.message_verifier('api_keys').generate(api_key))
    end
    
    it 'returns the machine when API key is valid' do
      result = VendingMachine.authenticate_with_api_key(api_key)
      expect(result).to eq(machine)
    end
    
    it 'returns nil when API key is invalid' do
      result = VendingMachine.authenticate_with_api_key('invalid_key')
      expect(result).to be_nil
    end
    
    it 'returns nil when API key is blank' do
      result = VendingMachine.authenticate_with_api_key('')
      expect(result).to be_nil
    end
    
    it 'returns nil when API key is nil' do
      result = VendingMachine.authenticate_with_api_key(nil)
      expect(result).to be_nil
    end
  end
  
  describe '#masked_api_key' do
    it 'returns masked version of API key digest' do
      machine = build(:vending_machine, tenant: tenant, api_key_digest: 'abcdef123456789')
      expect(machine.masked_api_key).to eq('****23456789')
    end
    
    it 'returns nil when api_key_digest is blank' do
      machine = build(:vending_machine, tenant: tenant, api_key_digest: nil)
      expect(machine.masked_api_key).to be_nil
    end
  end
  
  describe 'tenant scoping' do
    it 'scopes machines to their tenant' do
      tenant1 = create(:tenant)
      tenant2 = create(:tenant)
      
      machine1 = ActsAsTenant.with_tenant(tenant1) { create(:vending_machine, tenant: tenant1) }
      machine2 = ActsAsTenant.with_tenant(tenant2) { create(:vending_machine, tenant: tenant2) }
      
      ActsAsTenant.with_tenant(tenant1) do
        expect(VendingMachine.all).to include(machine1)
        expect(VendingMachine.all).not_to include(machine2)
      end
    end
  end
end
