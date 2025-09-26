Rails.application.routes.draw do
  devise_for :users
  root to: 'products#index'

  resources :products do
    member do
      post :favorite
      delete :unfavorite
    end
  end

  resources :favorites, only: [:index]
end
