# config/initializers/rack_attack.rb
# Protection contre les abus et attaques

class Rack::Attack
  # 🔒 CONFIGURATION

  # Activer rack-attack
  Rack::Attack.enabled = true

  # Cache store (utilise le cache Rails par défaut)
  Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

  # 🚫 BLOCKLIST : IPs malveillantes connues
  # Ajoute ici des IPs à bloquer définitivement si nécessaire
  # blocklist('block bad IPs') do |req|
  #   # Exemple : bloquer une IP spécifique
  #   # '123.456.789.0' == req.ip
  # end

  # ⏱️ THROTTLING : Limiter les requêtes par IP

  # 1. Limite globale : Max 300 requêtes par IP toutes les 5 minutes
  throttle('req/ip', limit: 300, period: 5.minutes) do |req|
    req.ip
  end

  # 2. Connexion : Max 4 tentatives de connexion par IP toutes les 20 secondes
  throttle('logins/ip', limit: 4, period: 20.seconds) do |req|
    if req.path == '/users/sign_in' && req.post?
      req.ip
    end
  end

  # 3. Connexion par email : Max 5 tentatives par email toutes les 20 secondes
  throttle('logins/email', limit: 5, period: 20.seconds) do |req|
    if req.path == '/users/sign_in' && req.post?
      # Extraction de l'email depuis les paramètres
      req.params.dig('user', 'email').presence
    end
  end

  # 4. Inscription : Max 3 créations de compte par IP par heure
  throttle('signups/ip', limit: 3, period: 1.hour) do |req|
    if req.path == '/users' && req.post?
      req.ip
    end
  end

  # 5. Création de produits : Max 20 produits par utilisateur par heure
  throttle('products/user', limit: 20, period: 1.hour) do |req|
    if req.path == '/products' && req.post?
      # Identifier l'utilisateur connecté via la session
      req.session[:user_id] if req.session
    end
  end

  # 6. Recherche : Max 60 recherches par IP par minute
  throttle('search/ip', limit: 60, period: 1.minute) do |req|
    if req.path == '/products' && req.get? && req.params['search'].present?
      req.ip
    end
  end

  # 🛡️ PROTECTION : Endpoints sensibles

  # Stripe webhooks : Limiter pour éviter les abus
  throttle('stripe/webhooks', limit: 100, period: 1.minute) do |req|
    if req.path.start_with?('/webhooks/stripe')
      req.ip
    end
  end

  # 📊 LOGGING : Logger les blocages

  ActiveSupport::Notifications.subscribe('throttle.rack_attack') do |_name, _start, _finish, _request_id, payload|
    req = payload[:request]
    Rails.logger.warn "[Rack::Attack] Throttled: #{req.env['rack.attack.matched']} - IP: #{req.ip} - Path: #{req.path}"
  end

  ActiveSupport::Notifications.subscribe('blocklist.rack_attack') do |_name, _start, _finish, _request_id, payload|
    req = payload[:request]
    Rails.logger.error "[Rack::Attack] Blocked: IP: #{req.ip} - Path: #{req.path}"
  end

  # ✅ RÉPONSE PERSONNALISÉE pour les requêtes bloquées

  self.throttled_responder = lambda do |request|
    match_data = request.env['rack.attack.match_data']
    now = match_data[:epoch_time]

    retry_after = if match_data[:period]
                    (match_data[:period] - (now % match_data[:period])).to_i
                  else
                    60
                  end

    [
      429, # Code HTTP 429 Too Many Requests
      {
        'Content-Type' => 'text/html; charset=utf-8',
        'Retry-After' => retry_after.to_s
      },
      [<<-HTML.html_safe
        <!DOCTYPE html>
        <html>
        <head>
          <meta charset="UTF-8">
          <title>Trop de requêtes</title>
          <style>
            body { font-family: Arial, sans-serif; text-align: center; padding: 50px; background: #f5f5f5; }
            h1 { color: #e74c3c; }
            p { color: #555; font-size: 18px; }
          </style>
        </head>
        <body>
          <h1>⚠️ Trop de requêtes</h1>
          <p>Veuillez réessayer dans #{retry_after} secondes.</p>
        </body>
        </html>
      HTML
      ]
    ]
  end
end
