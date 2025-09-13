Rails.application.routes.draw do
  get "resident_invitations/accept"

  # Resident invitations (accessible from any subdomain)
  get "residents/accept_invitation", to: "resident_invitations#accept", as: :accept_resident_invitation
  post "residents/accept_invitation", to: "resident_invitations#create_account"

  # Email preview in development
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Single Devise configuration for all subdomains
  devise_for :users, controllers: { sessions: "users/sessions" }

  # Admin subdomain routes
  constraints subdomain: "admin" do
    resources :companies
    resources :users, path: "manage_users"
    root "companies#index", as: :admin_root
  end

  # Tenant subdomain routes (for company subdomains)
  constraints subdomain: /^(?!admin$).+/ do
    root "dashboard#index", as: :tenant_root

    resources :buildings
    resources :apartments
    resources :residents do
      member do
        post :invite
        # Ensure a chat conversation exists and redirect to it
        post :open_chat, to: "conversations#ensure_for_resident"
        # GET shortcut for opening chat from resident page
        get :chat, to: "conversations#ensure_for_resident"
      end
    end

    # Conversations and messages
    resources :conversations, only: [ :index, :show ] do
      resources :messages, only: [ :create ]
    end

    # User management with custom path to avoid Devise conflicts
    scope "users" do
      get "/", to: "tenant_users#index", as: :tenant_users
      get "/new", to: "tenant_users#new", as: :new_tenant_user
      post "/", to: "tenant_users#create"
      get "/:id/edit", to: "tenant_users#edit", as: :edit_tenant_user
      patch "/:id", to: "tenant_users#update", as: :tenant_user
      put "/:id", to: "tenant_users#update"
      delete "/:id", to: "tenant_users#destroy"
      get "/:id", to: "tenant_users#show", constraints: { id: /\d+/ }
    end

    # Notifications
    resources :notifications, only: [ :index, :show, :new, :create ] do
      collection do
        get :apartments_for_building
      end
    end

    # Resident notifications
    resources :resident_notifications, only: [ :index, :show ], path: "my_notifications" do
      member do
        patch :mark_as_read
      end
    end

    # Resident chat entrypoint (residents use their one conversation)
    get "my_chat", to: "resident_conversations#show", as: :resident_chat

    # Dashboard route
    get "dashboard", to: "dashboard#index"
  end

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
