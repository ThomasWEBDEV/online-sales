# Be sure to restart your server when you modify this file.

# Configure parameters to be partially matched (e.g. passw matches password) and filtered from the log file.
# Use this to limit dissemination of sensitive information.
# See the ActiveSupport::ParameterFilter documentation for supported notations and behaviors.

Rails.application.config.filter_parameters += [
  # 🔒 Authentication & Authorization
  :passw, :password, :password_confirmation,
  :secret, :token, :_key, :api_key, :access_token, :refresh_token,
  :crypt, :salt, :certificate, :otp, :ssn,

  # 🔒 Payment Information
  :card_number, :cvv, :cvc, :card_cvv, :card_cvc,
  :credit_card, :stripe_token, :stripe_key,
  :iban, :bic, :account_number,

  # 🔒 Personal Data (RGPD)
  :phone, :mobile, :telephone,
  :address, :street, :postal_code, :zip_code,
  :social_security, :passport, :driver_license,

  # 🔒 Cloudinary & AWS
  :cloudinary_url, :cloudinary_secret,
  :aws_access_key_id, :aws_secret_access_key,

  # 🔒 Stripe Webhooks
  :stripe_signature, :webhook_secret
]
