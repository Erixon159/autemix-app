# frozen_string_literal: true

# Configure secure session cookies for authentication
Rails.application.config.session_store :cookie_store,
  key: '_autemix_admin_session',
  httponly: true,
  secure: Rails.env.production?,
  same_site: :strict,
  expire_after: 24.hours
