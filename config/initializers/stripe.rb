# Configuration Stripe
Rails.configuration.stripe = {
  publishable_key: ENV['STRIPE_PUBLISHABLE_KEY'],
  secret_key: ENV['STRIPE_SECRET_KEY']
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]

# Timeouts pour éviter blocage si Stripe ne répond pas
Stripe.open_timeout = 10  # secondes pour établir connexion
Stripe.read_timeout = 30  # secondes pour lire réponse
