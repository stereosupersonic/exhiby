require "sidekiq/web"
require_relative "../app/constraints/admin_constraint"

Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token

  # Sidekiq Web UI (admin only)
  constraints AdminConstraint.new do
    mount Sidekiq::Web => "/admin/sidekiq"
  end

  # Admin namespace
  namespace :admin do
    root to: "dashboard#index"
    resource :profile, only: %i[edit update]
    resources :articles
    resources :media_items do
      collection do
        get :search
        post :extract_exif
      end
      member do
        patch :submit_for_review
        patch :publish
        patch :reject
        patch :unpublish
      end
    end
    resources :media_tags, path: "tags"
    resources :techniques, except: [ :show ]
    resources :collection_categories, path: "sammlungs-kategorien", except: [ :show ]
    resources :collections, path: "sammlungen" do
      member do
        patch :publish
        patch :unpublish
        post :add_item
        delete :remove_item
      end
    end
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
    resources :pictures_of_the_day, path: "bild-des-tages"
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

  # Search
  get "suche", to: "search#index", as: :search

  # Public artists (German URL)
  resources :artists, only: %i[index show], path: "kunstschaffende", param: :slug

  # Collections (Land & Leute)
  get "land-und-leute", to: "collections#index", as: :land_und_leute
  get "land-und-leute/:slug", to: "collections#show", as: :collection

  # Placeholder pages (coming soon)
  get "ausstellungen", to: "welcome#coming_soon", as: :ausstellungen

  # Picture of the Day (Bild des Tages)
  get "bild-des-tages", to: "pictures_of_the_day#index", as: :pictures_of_the_day
  get "bild-des-tages/:date", to: "pictures_of_the_day#show", as: :picture_of_the_day,
                              constraints: { date: /\d{4}-\d{2}-\d{2}/ }
end
