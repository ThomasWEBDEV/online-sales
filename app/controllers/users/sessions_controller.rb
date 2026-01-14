# app/controllers/users/sessions_controller.rb
class Users::SessionsController < Devise::SessionsController

  # AUDIT LOG : Connexion réussie
  def create
    super do |resource|
      Rails.logger.info "[AUDIT] User login successful - User: #{resource.id} (#{resource.email}), IP: #{request.remote_ip}, User-Agent: #{request.user_agent}"
    end
  end

  # AUDIT LOG : Déconnexion
  def destroy
    user_email = current_user&.email
    user_id = current_user&.id

    super do
      Rails.logger.info "[AUDIT] User logout - User: #{user_id} (#{user_email}), IP: #{request.remote_ip}"
    end
  end

  protected

  # AUDIT LOG : Échec de connexion
  def auth_options
    email = params.dig(:user, :email)
    Rails.logger.warn "[SECURITY] Login attempt - Email: #{email}, IP: #{request.remote_ip}"
    super
  end
end
