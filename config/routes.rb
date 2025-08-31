Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Single Devise configuration for all subdomains
  devise_for :users, controllers: { sessions: "users/sessions" }

  # Admin subdomain routes
  constraints subdomain: "admin" do
    resources :companies
    resources :users, path: 'manage_users'
    root "companies#index", as: :admin_root
  end

  # Tenant subdomain routes (for company subdomains)
  constraints subdomain: /^(?!admin$).+/ do
    root "dashboard#index", as: :tenant_root
    
    resources :buildings
    resources :apartments
    resources :tenant_users, path: 'users', as: 'tenant_users'
    
    # Dashboard route
    get 'dashboard', to: 'dashboard#index'
  end

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
