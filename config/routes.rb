Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token

  # Admin namespace
  namespace :admin do
    root to: "dashboard#index"
    resources :articles
  end

  # Public articles
  resources :articles, only: [ :index, :show ], param: :slug

  # Dashboard (authenticated users)
  get "dashboard", to: "dashboard#index"

  # Health check endpoint - always returns 200 OK
  get "up" => "rails/health#show", :as => :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "welcome#index"

  # Static pages
  get "impressum", to: "welcome#impressum"
  get "datenschutzerklaerung", to: "welcome#datenschutzerklaerung"
  get "team", to: "welcome#team"
end
