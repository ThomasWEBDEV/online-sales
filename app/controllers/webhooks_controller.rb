class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def stripe
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    endpoint_secret = ENV['STRIPE_WEBHOOK_SECRET']

    begin
      event = Stripe::Webhook.construct_event(
        payload, sig_header, endpoint_secret
      )
    rescue JSON::ParserError => e
      Rails.logger.error "❌ Webhook JSON error: #{e.message}"
      render json: { error: 'Invalid payload' }, status: 400
      return
    rescue Stripe::SignatureVerificationError => e
      Rails.logger.error "❌ Webhook signature error: #{e.message}"
      render json: { error: 'Invalid signature' }, status: 400
      return
    end

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
      Rails.logger.error "❌ Webhook processing error: #{e.class} - #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      render json: { error: 'Processing error', message: e.message }, status: 200
    end
  end

  private

  def handle_checkout_session_completed(event)
    session = event['data']['object']
    
    Rails.logger.info "🔔 Processing checkout.session.completed"
    Rails.logger.info "Session ID: #{session['id']}"
    
    order_id = session['metadata']['order_id']

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

    shipping_details = session['collected_information'] ? session['collected_information']['shipping_details'] : nil
    customer_details = session['customer_details']
    
    address = shipping_details ? shipping_details['address'] : (customer_details ? customer_details['address'] : {})
    
    Rails.logger.info "📍 Address data: #{address.inspect}"

    shipping_data = {
      stripe_payment_intent_id: session['payment_intent'],
      status: 'paid',
      shipping_name: (shipping_details ? shipping_details['name'] : nil) || (customer_details ? customer_details['name'] : nil) || 'Non renseigné',
      shipping_address_line1: address ? (address['line1'] || 'Non renseigné') : 'Non renseigné',
      shipping_address_line2: address ? address['line2'] : nil,
      shipping_city: address ? (address['city'] || 'Non renseigné') : 'Non renseigné',
      shipping_postal_code: address ? (address['postal_code'] || '00000') : '00000',
      shipping_country: address ? (address['country'] || 'FR') : 'FR',
      shipping_phone: customer_details ? customer_details['phone'] : nil
    }

    Rails.logger.info "💾 Updating order with: #{shipping_data.inspect}"

    if order.update(shipping_data)
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
