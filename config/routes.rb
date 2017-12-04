require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'

  namespace :api do
    resources :auctions, only: [:index]

    resources :drivers, only: :none do
      resources :auctions, only: [:update]
    end
  end

  namespace :admin do
    resources :auctions, only: [:create]
  end
end
