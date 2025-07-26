class Technician < ApplicationRecord
  acts_as_tenant :tenant
  has_secure_password  

  # Callbacks
  before_validation :normalize_email
  
  # Validations
  validates :first_name, presence: true, length: { maximum: 50 }
  validates :last_name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, uniqueness: { scope: :tenant_id, case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 }, if: :password_required?

  # Account lockout constants
  MAX_FAILED_ATTEMPTS = 5
  LOCKOUT_DURATION = 1.hour
  
  def full_name
    "#{first_name} #{last_name}"
  end
  
  def display_name
    full_name
  end

  # Account lockout methods
  def account_locked?
    locked_at.present? && locked_at > LOCKOUT_DURATION.ago
  end

  def increment_failed_attempts!
    self.failed_attempts += 1
    if failed_attempts >= MAX_FAILED_ATTEMPTS
      lock_account!
    else
      save!
    end
  end

  def reset_failed_attempts!
    update!(failed_attempts: 0, locked_at: nil)
  end

  def lock_account!
    update!(locked_at: Time.current)
  end

  def unlock_account!
    update!(locked_at: nil, failed_attempts: 0)
  end

  def record_login!(ip_address = nil)
    update!(last_login_at: Time.current, last_login_ip: ip_address)
    reset_failed_attempts! if failed_attempts > 0
  end

  private

  def password_required?
    password_digest.blank? || password.present?
  end
  
  def normalize_email
    self.email = email.downcase.strip if email.present?
  end
end
