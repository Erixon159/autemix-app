require 'rails_helper'

RSpec.describe Technician, type: :model do
  include ActiveSupport::Testing::TimeHelpers
  let(:tenant) { create(:tenant) }
  
  around(:each) do |example|
    ActsAsTenant.with_tenant(tenant) do
      example.run
    end
  end

  describe 'validations' do
    subject { build(:technician, tenant: tenant) }

    it { should validate_presence_of(:first_name) }
    it { should validate_length_of(:first_name).is_at_most(50) }
    it { should validate_presence_of(:last_name) }
    it { should validate_length_of(:last_name).is_at_most(50) }
    it { should validate_presence_of(:email) }
    it { should allow_value('user@example.com').for(:email) }
    it { should_not allow_value('invalid-email').for(:email) }
    it { should have_secure_password }
    it { should validate_length_of(:password).is_at_least(8) }
  end

  describe 'password validation' do
    let(:technician) { build(:technician, tenant: tenant) }

    it 'requires password on create' do
      technician.password = nil
      technician.password_confirmation = nil
      expect(technician).not_to be_valid
      expect(technician.errors[:password]).to include("can't be blank")
    end

    it 'requires minimum 8 characters' do
      technician.password = '1234567'
      technician.password_confirmation = '1234567'
      expect(technician).not_to be_valid
      expect(technician.errors[:password]).to include('is too short (minimum is 8 characters)')
    end

    it 'accepts valid password' do
      technician.password = 'password123'
      technician.password_confirmation = 'password123'
      expect(technician).to be_valid
    end
  end

  describe 'email normalization' do
    let(:technician) { build(:technician, tenant: tenant) }

    it 'normalizes email to lowercase' do
      technician.email = 'Jane.Smith@EXAMPLE.COM'
      technician.valid?
      expect(technician.email).to eq('jane.smith@example.com')
    end

    it 'strips whitespace from email' do
      technician.email = '  tech@example.com  '
      technician.valid?
      expect(technician.email).to eq('tech@example.com')
    end

    it 'prevents duplicate emails with different cases' do
      create(:technician, email: 'tech@example.com', tenant: tenant)
      duplicate_technician = build(:technician, email: 'TECH@EXAMPLE.COM', tenant: tenant)
      
      expect(duplicate_technician).not_to be_valid
      expect(duplicate_technician.errors[:email]).to include('has already been taken')
    end
  end

  describe '#full_name' do
    let(:technician) { build(:technician, first_name: 'Jane', last_name: 'Smith', tenant: tenant) }

    it 'returns first and last name combined' do
      expect(technician.full_name).to eq('Jane Smith')
    end
  end

  describe '#display_name' do
    let(:technician) { build(:technician, first_name: 'Jane', last_name: 'Smith', tenant: tenant) }

    it 'returns the full name' do
      expect(technician.display_name).to eq('Jane Smith')
    end
  end

  describe 'account lockout functionality' do
    let(:technician) { create(:technician, tenant: tenant) }

    describe '#account_locked?' do
      it 'returns false when not locked' do
        expect(technician.account_locked?).to be false
      end

      it 'returns true when recently locked' do
        technician.update!(locked_at: 30.minutes.ago)
        expect(technician.account_locked?).to be true
      end

      it 'returns false when lock has expired' do
        technician.update!(locked_at: 2.hours.ago)
        expect(technician.account_locked?).to be false
      end
    end

    describe '#increment_failed_attempts!' do
      it 'increments failed attempts counter' do
        expect { technician.increment_failed_attempts! }.to change { technician.failed_attempts }.from(0).to(1)
      end

      it 'locks account after max attempts' do
        technician.update!(failed_attempts: 4)
        expect { technician.increment_failed_attempts! }.to change { technician.locked_at }.from(nil)
        expect(technician.failed_attempts).to eq(5)
      end
    end

    describe '#reset_failed_attempts!' do
      it 'resets failed attempts and unlocks account' do
        technician.update!(failed_attempts: 3, locked_at: Time.current)
        technician.reset_failed_attempts!
        
        technician.reload
        expect(technician.failed_attempts).to eq(0)
        expect(technician.locked_at).to be_nil
      end
    end

    describe '#lock_account!' do
      it 'sets locked_at timestamp' do
        expect { technician.lock_account! }.to change { technician.locked_at }.from(nil)
      end
    end

    describe '#unlock_account!' do
      it 'clears locked_at and failed_attempts' do
        technician.update!(locked_at: Time.current, failed_attempts: 3)
        technician.unlock_account!
        
        technician.reload
        expect(technician.locked_at).to be_nil
        expect(technician.failed_attempts).to eq(0)
      end
    end

    describe '#record_login!' do
      let(:ip_address) { '192.168.1.1' }

      it 'updates last login timestamp and IP' do
        travel_to Time.current do
          technician.record_login!(ip_address)
          
          technician.reload
          expect(technician.last_login_at).to eq(Time.current)
          expect(technician.last_login_ip).to eq(ip_address)
        end
      end

      it 'resets failed attempts on successful login' do
        technician.update!(failed_attempts: 3)
        technician.record_login!(ip_address)
        
        technician.reload
        expect(technician.failed_attempts).to eq(0)
      end
    end
  end

  describe 'multi-tenancy' do
    let(:tenant1) { create(:tenant) }
    let(:tenant2) { create(:tenant) }

    it 'allows same email in different tenants' do
      ActsAsTenant.with_tenant(tenant1) do
        create(:technician, email: 'tech@example.com', tenant: tenant1)
      end

      ActsAsTenant.with_tenant(tenant2) do
        expect {
          create(:technician, email: 'tech@example.com', tenant: tenant2)
        }.not_to raise_error
      end
    end

    it 'prevents duplicate emails within same tenant' do
      ActsAsTenant.with_tenant(tenant1) do
        create(:technician, email: 'tech@example.com', tenant: tenant1)
        
        expect {
          create(:technician, email: 'tech@example.com', tenant: tenant1)
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end
