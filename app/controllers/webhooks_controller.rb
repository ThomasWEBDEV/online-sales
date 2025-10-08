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
      render json: { error: 'Invalid payload' }, status: 400
      return
    rescue Stripe::SignatureVerificationError => e
      # Signature invalide
      render json: { error: 'Invalid signature' }, status: 400
      return
    end

    # Gérer les événements Stripe
    case event['type']
    when 'checkout.session.completed'
      handle_checkout_session_completed(event)
    when 'payment_intent.succeeded'
      handle_payment_intent_succeeded(event)
    when 'payment_intent.payment_failed'
      handle_payment_failed(event)
    else
      Rails.logger.info "Unhandled event type: #{event['type']}"
    end

    render json: { message: 'success' }, status: 200
  end

  private

  def handle_checkout_session_completed(event)
    session = event['data']['object']
    order_id = session['metadata']['order_id']

    return unless order_id

    order = Order.find_by(id: order_id)
    return unless order

    # Mettre à jour la commande avec les infos Stripe
    order.update!(
      stripe_payment_intent_id: session['payment_intent'],
      status: 'paid',
      # Récupérer l'adresse de livraison depuis Stripe
      shipping_name: session.dig('shipping_details', 'name') || session.dig('customer_details', 'name'),
      shipping_address_line1: session.dig('shipping_details', 'address', 'line1') || session.dig('customer_details', 'address', 'line1'),
      shipping_address_line2: session.dig('shipping_details', 'address', 'line2') || session.dig('customer_details', 'address', 'line2'),
      shipping_city: session.dig('shipping_details', 'address', 'city') || session.dig('customer_details', 'address', 'city'),
      shipping_postal_code: session.dig('shipping_details', 'address', 'postal_code') || session.dig('customer_details', 'address', 'postal_code'),
      shipping_country: session.dig('shipping_details', 'address', 'country') || session.dig('customer_details', 'address', 'country'),
      shipping_phone: session.dig('customer_details', 'phone')
    )

    # Marquer le produit comme vendu
    order.product.update!(sold: true)

    Rails.logger.info "Order ##{order.id} marked as paid"

    # TODO: Envoyer email de confirmation (prochain commit)
    # OrderMailer.payment_confirmed(order).deliver_later
  end

  def handle_payment_intent_succeeded(event)
    payment_intent = event['data']['object']
    Rails.logger.info "PaymentIntent succeeded: #{payment_intent['id']}"
  end

  def handle_payment_failed(event)
    payment_intent = event['data']['object']
    order = Order.find_by(stripe_payment_intent_id: payment_intent['id'])

    if order
      order.update(status: 'cancelled')
      order.product.update(sold: false)
      Rails.logger.error "Payment failed for Order ##{order.id}"
    end
  end
end
