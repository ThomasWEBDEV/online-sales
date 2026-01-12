# app/controllers/users/registrations_controller.rb
class Users::RegistrationsController < Devise::RegistrationsController
  before_action :check_honeypot, only: [:create]

  private

  # SÉCURITÉ : Protection anti-bot (Honeypot)
  def check_honeypot
    honeypot_field = params[:user][:website]

    if honeypot_field.present?
      # AUDIT LOG : Bot détecté
      Rails.logger.warn "[SECURITY] Bot registration attempt detected - Honeypot field filled: '#{honeypot_field}', IP: #{request.remote_ip}, Email: #{params[:user][:email]}"

      # Rediriger sans message pour ne pas révéler la protection
      redirect_to root_path and return
    end
  end
end
