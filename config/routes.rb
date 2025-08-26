Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Admin subdomain routes
  constraints subdomain: "admin" do
    resources :companies
    resources :users
    root "companies#index", as: :admin_root
  end

  # Tenant subdomain routes (for company subdomains)  
  constraints subdomain: /^(?!admin$).+/ do
    devise_for :users
    # Add your tenant-specific routes here
    root "dashboard#index", as: :tenant_root
  end

  # Default routes (no subdomain)
  devise_for :users

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
