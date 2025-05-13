Rails.application.routes.draw do
  ActiveAdmin.routes(self)
  # Application routes
  ## root
  root "home#index"

  ## 메인 페이지
  get "/home", to: "home#index"

  ## 의안 관련
  resources :bills, only: [ :index, :show ]


  # 인증 관련
  resource :session, only: [ :destroy ]
  # resources :passwords, param: :token

  ## OAuth
  namespace :oauth do
    get "/:provider/callback" => "omni_auths#create", as: :callback
  end
  get "/login", to: "login#index", as: :login


  # Rails system related

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
