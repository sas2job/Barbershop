Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
  namespace :staff do
    resource :dashboard, only: :show
  end
  namespace :admin do
    resource :dashboard, only: :show
    resources :users, only: %i[ new create ]
    resources :bookings, only: %i[ edit update ]
    resources :working_hours, only: %i[ index update ]
    resources :barber_working_hours, only: %i[ index create update destroy ]
    resources :time_offs, only: %i[ index create destroy ]
  end
  resources :bookings, only: %i[ new create show ], param: :public_token do
    member do
      post :cancel
      get :reschedule
      post :reschedule
    end
  end
  root "services#index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
