# frozen_string_literal: true

Devise.setup do |config|
  # ==> Mailer Configuration
  config.mailer_sender = ENV.fetch('MAILER_FROM', 'please-change-me@example.com')

  # ==> ORM configuration
  require 'devise/orm/active_record'

  # ==> Configuration for :database_authenticatable
  # Augmente la sécurité du hash bcrypt (12 par défaut, on garde)
  config.stretches = Rails.env.test? ? 1 : 13

  # 🔒 SÉCURITÉ : Utilise un pepper pour ajouter une couche de sécurité
  # config.pepper = ENV.fetch('DEVISE_PEPPER') { Rails.application.credentials.devise_pepper }

  # ==> Configuration for :confirmable
  # Temps avant expiration du token de confirmation
  config.confirm_within = 3.days

  # ==> Configuration for :rememberable
  # Durée du "Se souvenir de moi"
  config.remember_for = 2.weeks

  # 🔒 SÉCURITÉ : Expire les cookies "remember me" lors du sign out
  config.expire_all_remember_me_on_sign_out = true

  # ==> Configuration for :validatable
  # Règles strictes pour les mots de passe
  config.password_length = 12..128
  config.email_regexp = /\A[^@\s]+@[^@\s]+\z/

  # ==> Configuration for :timeoutable
  # Déconnexion automatique après inactivité
  config.timeout_in = 30.minutes

  # ==> Configuration for :lockable
  # 🔒 SÉCURITÉ : Verrouillage après tentatives échouées
  config.lock_strategy = :failed_attempts
  config.unlock_keys = [:email]
  config.unlock_strategy = :both
  config.maximum_attempts = 5
  config.unlock_in = 1.hour
  config.last_attempt_warning = true

  # ==> Configuration for :recoverable
  # Durée de validité du token de reset password
  config.reset_password_within = 6.hours

  # 🔒 SÉCURITÉ : Clés pour reset password
  config.reset_password_keys = [:email]

  # ==> Scopes configuration
  config.scoped_views = false
  config.default_scope = :user
  config.sign_out_all_scopes = true

  # ==> Navigation configuration
  config.navigational_formats = ['*/*', :html, :turbo_stream]
  config.sign_out_via = :delete

  # ==> OmniAuth
  # config.omniauth :github, ENV['GITHUB_KEY'], ENV['GITHUB_SECRET'], scope: 'user,public_repo'

  # ==> Warden configuration
  # 🔒 SÉCURITÉ : Protection contre le timing attack
  config.paranoid = true

  # 🔒 SÉCURITÉ : Évite les attaques CSRF
  config.clean_up_csrf_token_on_authentication = true

  # 🔒 SÉCURITÉ : Ne stocke pas la session pour certaines stratégies
  config.skip_session_storage = [:http_auth]

  # ==> Configuration for :registerable
  # 🔒 SÉCURITÉ : Envoie notification si email changé
  config.send_email_changed_notification = true

  # 🔒 SÉCURITÉ : Envoie notification si password changé
  config.send_password_change_notification = true

end
