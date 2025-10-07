Rails.application.routes.draw do
  devise_for :users
  root to: 'products#index'

  resources :products do
    member do
      post :favorite
      delete :unfavorite
    end

    # Checkout pour un produit spécifique
    resources :checkouts, only: [:create]
  end

  resources :favorites, only: [:index]

  # Profils publics des vendeurs
  resources :users, only: [:show]

  # Gestion des commandes
  resources :orders, only: [:show] do
    member do
      patch :mark_as_shipped
      patch :cancel
    end
  end

  # Dashboards commandes
  get '/my/purchases', to: 'orders#purchases', as: 'my_purchases'
  get '/my/sales', to: 'orders#sales', as: 'my_sales'

  # Routes Stripe Checkout
  get '/checkout/success', to: 'checkouts#success', as: 'checkout_success'
  get '/checkout/cancel', to: 'checkouts#cancel', as: 'checkout_cancel'

  # Webhook Stripe (pour le prochain commit)
  post '/webhooks/stripe', to: 'webhooks#stripe'
end
