Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions'
  }
  root to: 'products#index'

  # Letter Opener Web (emails en dev)
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  resources :products do
    member do
      post :favorite
      delete :unfavorite
    end
    resources :checkouts, only: [:create]
  end

  resources :favorites, only: [:index]
  resources :users, only: [:show]

  resources :orders, only: [:show] do
    member do
      patch :mark_as_shipped
      patch :cancel
    end
  end

  get '/my/purchases', to: 'orders#purchases', as: 'my_purchases'
  get '/my/sales', to: 'orders#sales', as: 'my_sales'

  get '/checkout/success', to: 'checkouts#success', as: 'checkout_success'
  get '/checkout/cancel', to: 'checkouts#cancel', as: 'checkout_cancel'

  post '/webhooks/stripe', to: 'webhooks#stripe'
end
