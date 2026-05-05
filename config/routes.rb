Rails.application.routes.draw do
  root "runs#new"

  resources :runs, only: [:new, :create, :show] do
    get :complete, on: :member
    resources :attempts, only: [:update]
  end

  namespace :admin do
    resources :riddles
    root "riddles#index"
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
