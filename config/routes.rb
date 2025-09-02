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
    resources :residents
    
    # User management with custom path to avoid Devise conflicts
    scope 'users' do
      get '/', to: 'tenant_users#index', as: :tenant_users
      get '/new', to: 'tenant_users#new', as: :new_tenant_user
      post '/', to: 'tenant_users#create'
      get '/:id/edit', to: 'tenant_users#edit', as: :edit_tenant_user
      patch '/:id', to: 'tenant_users#update', as: :tenant_user
      put '/:id', to: 'tenant_users#update'
      delete '/:id', to: 'tenant_users#destroy'
      get '/:id', to: 'tenant_users#show', constraints: { id: /\d+/ }
    end
    
    # Dashboard route
    get 'dashboard', to: 'dashboard#index'
  end

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
