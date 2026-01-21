Rails.application.routes.draw do
  # === AUTHENTICATION ===
  # Devise routes avec controllers personnalisés pour audit logging et honeypot
  devise_for :users, controllers: {
    registrations: 'users/registrations',  # Honeypot anti-bot
    sessions: 'users/sessions'             # Audit logging connexions
  }

  # Page d'accueil
  root to: 'products#index'

  # === DEVELOPMENT TOOLS ===
  # Letter Opener Web pour tester les emails en développement
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  # === PRODUCTS ===
  # CRUD produits + favoris + paiement
  resources :products do
    member do
      post :favorite      # Ajouter aux favoris
      delete :unfavorite  # Retirer des favoris
    end
    resources :checkouts, only: [:create]  # Créer session Stripe
  end

  # === FAVORITES ===
  # Liste des produits favoris de l'utilisateur
  resources :favorites, only: [:index]

  # === USERS ===
  # Profil public utilisateur (vendeur)
  resources :users, only: [:show]

  # === ORDERS ===
  # Gestion des commandes
  resources :orders, only: [:show] do
    member do
      patch :mark_as_shipped  # Vendeur marque comme expédié
      patch :cancel           # Annulation commande
    end
  end

  # Routes custom pour les achats/ventes
  get '/my/purchases', to: 'orders#purchases', as: 'my_purchases'  # Mes achats
  get '/my/sales', to: 'orders#sales', as: 'my_sales'              # Mes ventes

  # === CHECKOUT ===
  # Pages de retour Stripe
  get '/checkout/success', to: 'checkouts#success', as: 'checkout_success'
  get '/checkout/cancel', to: 'checkouts#cancel', as: 'checkout_cancel'

  # === WEBHOOKS ===
  # Webhooks Stripe pour mise à jour commandes
  post '/webhooks/stripe', to: 'webhooks#stripe'
end
