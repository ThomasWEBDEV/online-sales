class WebhooksController < ApplicationController
  # Désactiver la protection CSRF pour les webhooks Stripe
  skip_before_action :verify_authenticity_token

  def stripe
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    endpoint_secret = ENV['STRIPE_WEBHOOK_SECRET']

    begin
      # Vérifier la signature du webhook
      event = Stripe::Webhook.construct_event(
        payload, sig_header, endpoint_secret
      )
    rescue JSON::ParserError => e
      # Payload invalide
      Rails.logger.error "❌ Webhook JSON error: #{e.message}"
      render json: { error: 'Invalid payload' }, status: 400
      return
    rescue Stripe::SignatureVerificationError => e
      # Signature invalide
      Rails.logger.error "❌ Webhook signature error: #{e.message}"
      render json: { error: 'Invalid signature' }, status: 400
      return
    end

    # Gérer les événements Stripe
    begin
      case event['type']
      when 'checkout.session.completed'
        handle_checkout_session_completed(event)
      when 'payment_intent.succeeded'
        handle_payment_intent_succeeded(event)
      when 'payment_intent.payment_failed'
        handle_payment_failed(event)
      else
        Rails.logger.info "ℹ️ Unhandled event type: #{event['type']}"
      end

      render json: { message: 'success' }, status: 200
    rescue StandardError => e
      # Capturer TOUTES les erreurs pour ne pas retourner 500
      Rails.logger.error "❌ Webhook processing error: #{e.class} - #{e.message}"
      Rails.logger.error e.backtrace.join("\n")

      # Retourner 200 quand même pour ne pas que Stripe retry indéfiniment
      render json: { error: 'Processing error', message: e.message }, status: 200
    end
  end

  private

  def handle_checkout_session_completed(event)
    session = event['data']['object']

    Rails.logger.info "🔔 Processing checkout.session.completed"
    Rails.logger.info "Session ID: #{session['id']}"

    # IMPORTANT : Vérifier que order_id existe dans metadata
    order_id = session.dig('metadata', 'order_id')

    unless order_id
      Rails.logger.error "❌ No order_id in session metadata"
      Rails.logger.error "Session metadata: #{session['metadata'].inspect}"
      return
    end

    Rails.logger.info "📦 Looking for Order ##{order_id}"

    order = Order.find_by(id: order_id)

    unless order
      Rails.logger.error "❌ Order ##{order_id} not found in database"
      return
    end

    # CORRECTION : Extraire l'adresse avec gestion des nil
    shipping_details = session['shipping_details'] || session['shipping'] || {}
    customer_details = session['customer_details'] || {}

    # Priorité: shipping_details > customer_details
    address = shipping_details['address'] || customer_details['address'] || {}

    Rails.logger.info "📍 Address data: #{address.inspect}"

    # Construire les données d'adresse avec valeurs par défaut sécurisées
    shipping_data = {
      stripe_payment_intent_id: session['payment_intent'],
      status: 'paid',
      shipping_name: shipping_details['name'] || customer_details['name'] || 'Non renseigné',
      shipping_address_line1: address['line1'] || 'Non renseigné',
      shipping_address_line2: address['line2'],
      shipping_city: address['city'] || 'Non renseigné',
      shipping_postal_code: address['postal_code'] || '00000',
      shipping_country: address['country'] || 'FR',
      shipping_phone: customer_details['phone']
    }

    Rails.logger.info "💾 Updating order with: #{shipping_data.inspect}"

    # Mettre à jour la commande
    if order.update(shipping_data)
      # Marquer le produit comme vendu
      if order.product.update(sold: true)
        Rails.logger.info "✅ Order ##{order.id} marked as PAID"
        Rails.logger.info "✅ Product ##{order.product.id} marked as SOLD"
      else
        Rails.logger.error "❌ Failed to mark product as sold: #{order.product.errors.full_messages.join(', ')}"
      end
    else
      Rails.logger.error "❌ Failed to update Order ##{order.id}"
      Rails.logger.error "Errors: #{order.errors.full_messages.join(', ')}"
    end
  end

  def handle_payment_intent_succeeded(event)
    payment_intent = event['data']['object']
    Rails.logger.info "✅ PaymentIntent succeeded: #{payment_intent['id']}"
  end

  def handle_payment_failed(event)
    payment_intent = event['data']['object']
    Rails.logger.warn "⚠️ Payment failed for PaymentIntent: #{payment_intent['id']}"

    order = Order.find_by(stripe_payment_intent_id: payment_intent['id'])

    if order
      order.update(status: 'cancelled')
      order.product.update(sold: false)
      Rails.logger.error "❌ Payment failed for Order ##{order.id} - Order cancelled"
    end
  end
end
