class ApplicationController < ActionController::Base
  include Pundit::Authorization
  include Pagy::Backend  # Pagination backend

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def user_not_authorized
    flash[:alert] = "Vous n'êtes pas autorisé à effectuer cette action."
    redirect_to safe_redirect_url(request.referrer)
  end

  # SÉCURITÉ : Protection Open Redirect
  # Valide que l'URL de redirection est sûre (même domaine)
  def safe_redirect_url(url)
    return root_path if url.blank?

    begin
      uri = URI.parse(url)

      # SÉCURITÉ : Autoriser uniquement les URLs relatives ou du même domaine
      if uri.relative? || (uri.host == request.host)
        url
      else
        # AUDIT LOG : Tentative de redirection externe bloquée
        Rails.logger.warn "[SECURITY] Open redirect attempt blocked - Requested URL: #{url}, User: #{current_user&.id || 'Guest'}, IP: #{request.remote_ip}"
        root_path
      end
    rescue URI::InvalidURIError => e
      # AUDIT LOG : URL invalide détectée
      Rails.logger.warn "[SECURITY] Invalid redirect URL detected - URL: #{url}, Error: #{e.message}, User: #{current_user&.id || 'Guest'}, IP: #{request.remote_ip}"
      root_path
    end
  end

  # HELPER : Redirection sécurisée avec fallback
  def safe_redirect_back(fallback_location: root_path, **options)
    redirect_to safe_redirect_url(request.referrer) || fallback_location, **options
  end
  helper_method :safe_redirect_back
end
