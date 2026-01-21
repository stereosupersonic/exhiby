Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token

  # Admin namespace
  namespace :admin do
    root to: "dashboard#index"
    resource :profile, only: %i[edit update]
    resources :articles
    resources :media_items do
      collection do
        get :search
      end
      member do
        patch :submit_for_review
        patch :publish
        patch :reject
        patch :unpublish
      end
    end
    resources :media_tags, path: "tags"
    resources :techniques
    resources :artists do
      member do
        patch :publish
        patch :unpublish
      end
    end
    resources :users, only: %i[index new create edit update] do
      member do
        patch :deactivate
        patch :activate
      end
    end
  end

  # Public articles
  resources :articles, only: [ :index, :show ], param: :slug

  # Dashboard redirects to admin
  get "dashboard", to: redirect("/admin"), as: :dashboard

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
  get "coming-soon", to: "welcome#coming_soon", as: :coming_soon

  # Public artists (German URL)
  resources :artists, only: %i[index show], path: "kunstschaffende", param: :slug

  # Placeholder pages (coming soon)
  get "land-und-leute", to: "welcome#coming_soon", as: :land_und_leute
  get "ausstellungen", to: "welcome#coming_soon", as: :ausstellungen
  get "bild-der-woche", to: "welcome#coming_soon", as: :bild_der_woche
end
