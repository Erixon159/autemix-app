class Tenant < ApplicationRecord
  # Reserved subdomains that cannot be used by tenants
  RESERVED_SUBDOMAINS = %w[
    www api admin app mail ftp localhost
    support help docs blog news
    cdn assets static media files
    test staging dev development
    dashboard console panel
    auth login signup register
    billing payment payments
    status health ping
    webhook webhooks callback
    mobile ios android
    beta alpha demo sandbox
    root system internal
    autemix platform service
  ].freeze
  
  # Validations
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :subdomain, presence: true, 
                       uniqueness: { case_sensitive: false },
                       format: { with: /\A[a-z0-9][a-z0-9\-]*[a-z0-9]\z/i, 
                                message: "must contain only letters, numbers, and hyphens" },
                       length: { minimum: 2, maximum: 63 },
                       exclusion: { in: RESERVED_SUBDOMAINS, 
                                   message: "is reserved" }
  
  # Scopes
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  
  # Callbacks
  before_validation :normalize_subdomain
  before_create :set_default_active_status
  
  # Class methods
  def self.find_by_subdomain(subdomain)
    return nil if subdomain.blank?
    find_by(subdomain: subdomain.downcase.strip)
  end
  
  def self.current
    ActsAsTenant.current_tenant
  end
  
  def self.subdomain_reserved?(subdomain)
    return true if subdomain.blank?
    RESERVED_SUBDOMAINS.include?(subdomain.downcase.strip)
  end
  
  def self.available_subdomain?(subdomain)
    return false if subdomain_reserved?(subdomain)
    !exists?(subdomain: subdomain.downcase.strip)
  end
  
  # Instance methods
  def to_param
    subdomain
  end
  
  def full_domain(base_domain = 'autemix.com')
    "#{subdomain}.#{base_domain}"
  end
  
  def activate!
    update!(active: true)
  end
  
  def deactivate!
    update!(active: false)
  end
  
  private
  
  def normalize_subdomain
    self.subdomain = subdomain&.downcase&.strip
  end
  
  def set_default_active_status
    self.active = true if active.nil?
  end
end
