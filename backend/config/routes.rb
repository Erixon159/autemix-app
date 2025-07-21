Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  
  # Custom health check endpoint for Docker containers
  get "health" => "health#show", as: :health_check
  
  # Sidekiq web interface (for development and admin monitoring)
  if Rails.env.development? || Rails.env.staging?
    mount Sidekiq::Web => '/sidekiq'
  end

  # Defines the root path route ("/")
  # root "posts#index"
end
