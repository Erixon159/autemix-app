class VendingMachine < ApplicationRecord
  acts_as_tenant :tenant

  validates :name, presence: true, length: { maximum: 100 }
  validates :location, presence: true, length: { maximum: 255 }
  validates :api_key_digest, presence: true, uniqueness: true
  
  # Generate and encrypt API key
  def generate_api_key!
    raw_key = SecureRandom.hex(32)
    self.api_key_digest = Rails.application.message_verifier('api_keys').generate(raw_key)
    raw_key
  end
  
  # Verify API key
  def self.authenticate_with_api_key(api_key)
    return nil if api_key.blank?
    
    # Search across all tenants for the machine with this API key
    ActsAsTenant.without_tenant do
      VendingMachine.all.find do |machine|
        begin
          stored_key = Rails.application.message_verifier('api_keys').verify(machine.api_key_digest)
          stored_key == api_key
        rescue ActiveSupport::MessageVerifier::InvalidSignature
          false
        end
      end
    end
  rescue => e
    Rails.logger.error "API key authentication error: #{e.message}"
    nil
  end
  
  def masked_api_key
    return nil unless api_key_digest.present?
    "****#{api_key_digest.last(8)}"
  end
end
