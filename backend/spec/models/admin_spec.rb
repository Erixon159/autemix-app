require 'rails_helper'

RSpec.describe Admin, type: :model do
  include ActiveSupport::Testing::TimeHelpers
  let(:tenant) { create(:tenant) }
  
  around(:each) do |example|
    ActsAsTenant.with_tenant(tenant) do
      example.run
    end
  end

  describe 'validations' do
    subject { build(:admin, tenant: tenant) }

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
    let(:admin) { build(:admin, tenant: tenant) }

    it 'requires password on create' do
      admin.password = nil
      admin.password_confirmation = nil
      expect(admin).not_to be_valid
      expect(admin.errors[:password]).to include("can't be blank")
    end

    it 'requires minimum 8 characters' do
      admin.password = '1234567'
      admin.password_confirmation = '1234567'
      expect(admin).not_to be_valid
      expect(admin.errors[:password]).to include('is too short (minimum is 8 characters)')
    end

    it 'accepts valid password' do
      admin.password = 'password123'
      admin.password_confirmation = 'password123'
      expect(admin).to be_valid
    end
  end

  describe 'email normalization' do
    let(:admin) { build(:admin, tenant: tenant) }

    it 'normalizes email to lowercase' do
      admin.email = 'John.Doe@EXAMPLE.COM'
      admin.valid?
      expect(admin.email).to eq('john.doe@example.com')
    end

    it 'strips whitespace from email' do
      admin.email = '  user@example.com  '
      admin.valid?
      expect(admin.email).to eq('user@example.com')
    end

    it 'prevents duplicate emails with different cases' do
      create(:admin, email: 'user@example.com', tenant: tenant)
      duplicate_admin = build(:admin, email: 'USER@EXAMPLE.COM', tenant: tenant)
      
      expect(duplicate_admin).not_to be_valid
      expect(duplicate_admin.errors[:email]).to include('has already been taken')
    end
  end

  describe '#full_name' do
    let(:admin) { build(:admin, first_name: 'John', last_name: 'Doe', tenant: tenant) }

    it 'returns first and last name combined' do
      expect(admin.full_name).to eq('John Doe')
    end
  end

  describe '#display_name' do
    let(:admin) { build(:admin, first_name: 'John', last_name: 'Doe', tenant: tenant) }

    it 'returns the full name' do
      expect(admin.display_name).to eq('John Doe')
    end
  end

  describe 'account lockout functionality' do
    let(:admin) { create(:admin, tenant: tenant) }

    describe '#account_locked?' do
      it 'returns false when not locked' do
        expect(admin.account_locked?).to be false
      end

      it 'returns true when recently locked' do
        admin.update!(locked_at: 30.minutes.ago)
        expect(admin.account_locked?).to be true
      end

      it 'returns false when lock has expired' do
        admin.update!(locked_at: 2.hours.ago)
        expect(admin.account_locked?).to be false
      end
    end

    describe '#increment_failed_attempts!' do
      it 'increments failed attempts counter' do
        expect { admin.increment_failed_attempts! }.to change { admin.failed_attempts }.from(0).to(1)
      end

      it 'locks account after max attempts' do
        admin.update!(failed_attempts: 4)
        expect { admin.increment_failed_attempts! }.to change { admin.locked_at }.from(nil)
        expect(admin.failed_attempts).to eq(5)
      end
    end

    describe '#reset_failed_attempts!' do
      it 'resets failed attempts and unlocks account' do
        admin.update!(failed_attempts: 3, locked_at: Time.current)
        admin.reset_failed_attempts!
        
        admin.reload
        expect(admin.failed_attempts).to eq(0)
        expect(admin.locked_at).to be_nil
      end
    end

    describe '#lock_account!' do
      it 'sets locked_at timestamp' do
        expect { admin.lock_account! }.to change { admin.locked_at }.from(nil)
      end
    end

    describe '#unlock_account!' do
      it 'clears locked_at and failed_attempts' do
        admin.update!(locked_at: Time.current, failed_attempts: 3)
        admin.unlock_account!
        
        admin.reload
        expect(admin.locked_at).to be_nil
        expect(admin.failed_attempts).to eq(0)
      end
    end

    describe '#record_login!' do
      let(:ip_address) { '192.168.1.1' }

      it 'updates last login timestamp and IP' do
        travel_to Time.current do
          admin.record_login!(ip_address)
          
          admin.reload
          expect(admin.last_login_at).to eq(Time.current)
          expect(admin.last_login_ip).to eq(ip_address)
        end
      end

      it 'resets failed attempts on successful login' do
        admin.update!(failed_attempts: 3)
        admin.record_login!(ip_address)
        
        admin.reload
        expect(admin.failed_attempts).to eq(0)
      end
    end
  end

  describe 'multi-tenancy' do
    let(:tenant1) { create(:tenant) }
    let(:tenant2) { create(:tenant) }

    it 'allows same email in different tenants' do
      ActsAsTenant.with_tenant(tenant1) do
        create(:admin, email: 'admin@example.com', tenant: tenant1)
      end

      ActsAsTenant.with_tenant(tenant2) do
        expect {
          create(:admin, email: 'admin@example.com', tenant: tenant2)
        }.not_to raise_error
      end
    end

    it 'prevents duplicate emails within same tenant' do
      ActsAsTenant.with_tenant(tenant1) do
        create(:admin, email: 'admin@example.com', tenant: tenant1)
        
        expect {
          create(:admin, email: 'admin@example.com', tenant: tenant1)
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end
