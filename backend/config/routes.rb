Rails.application.routes.draw do
  # API routes for custom JWT authentication (to be implemented)
  namespace :api do
    namespace :v1 do
      namespace :auth do
        # Custom authentication routes will be added here
      end
    end
  end
  
  # Custom health check endpoint for Docker containers
  get "health" => "health#show", as: :health_check
  
  # Sidekiq web interface (for development and admin monitoring)
  if Rails.env.development? || Rails.env.staging?
    mount Sidekiq::Web => '/sidekiq'
  end
end
