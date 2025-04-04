Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

    # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
    # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
    # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

    resources :bills, only: [ :index, :show ] do
      # resources :bill_events, only: [ :index, :show ]
    end

    # resources :sponsors, only: [ :index, :show ]
    # resources :departments, only: [ :index, :show ]

    # Root path
    # NOTE: 스프린트 1에서는 bills#index로 설정
    root "bills#index"
end
