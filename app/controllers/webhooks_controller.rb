class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def stripe
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    endpoint_secret = ENV['STRIPE_WEBHOOK_SECRET']

    # 🔒 SÉCURITÉ : Vérifier que le secret existe
    unless endpoint_secret.present?
      Rails.logger.error "[SECURITY] STRIPE_WEBHOOK_SECRET not configured!"
      render json: { error: 'Server configuration error' }, status: 500
      return
    end

    # 🔒 SÉCURITÉ : Log de la tentative de webhook
    Rails.logger.info "[WEBHOOK] Stripe webhook received - IP: #{request.remote_ip}, Event: pending verification"

    begin
      event = Stripe::Webhook.construct_event(
        payload, sig_header, endpoint_secret
      )
    rescue JSON::ParserError => e
      # 🚨 AUDIT LOG : Payload JSON invalide
      Rails.logger.error "[SECURITY] Webhook JSON error - IP: #{request.remote_ip}, Error: #{e.message}"
      render json: { error: 'Invalid payload' }, status: 400
      return
    rescue Stripe::SignatureVerificationError => e
      # 🚨 AUDIT LOG : Signature invalide (potentielle attaque)
      Rails.logger.error "[SECURITY] Webhook signature verification FAILED - IP: #{request.remote_ip}, Error: #{e.message}"
      render json: { error: 'Invalid signature' }, status: 400
      return
    end

    # ✅ AUDIT LOG : Webhook vérifié avec succès
    Rails.logger.info "[WEBHOOK] Signature verified - Event ID: #{event['id']}, Type: #{event['type']}, IP: #{request.remote_ip}"

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
      # 🚨 AUDIT LOG : Metadata manquante (suspect)
      Rails.logger.error "[SECURITY] No order_id in session metadata - Session: #{session['id']}, IP: #{request.remote_ip}"
      Rails.logger.error "Session metadata: #{session['metadata'].inspect}"
      return
    end

    Rails.logger.info "📦 Looking for Order ##{order_id}"

    order = Order.find_by(id: order_id)

    unless order
      # 🚨 AUDIT LOG : Order introuvable (potentielle manipulation)
      Rails.logger.error "[SECURITY] Order ##{order_id} not found - Session: #{session['id']}, IP: #{request.remote_ip}"
      return
    end

    # 🔒 SÉCURITÉ : Vérifier que la commande n'est pas déjà payée (protection double paiement)
    if order.status == 'paid'
      Rails.logger.warn "[SECURITY] Duplicate webhook detected - Order ##{order.id} already paid, Session: #{session['id']}, IP: #{request.remote_ip}"
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
        # 📊 AUDIT LOG : Paiement validé avec succès
        Rails.logger.info "[AUDIT] Payment validated - Order ##{order.id}, Product ##{order.product.id}, Buyer: #{order.buyer.email}, Amount: #{order.total_amount}€, Session: #{session['id']}"

        Rails.logger.info "✅ Order ##{order.id} marked as PAID"
        Rails.logger.info "✅ Product ##{order.product.id} marked as SOLD"

        # 📧 ENVOI DES EMAILS
        begin
          OrderMailer.purchase_confirmation(order).deliver_later
          OrderMailer.sale_notification(order).deliver_later
          Rails.logger.info "📧 Emails sent for Order ##{order.id}"
        rescue => e
          Rails.logger.error "❌ Email error: #{e.message}"
        end
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

    # ⚠️ AUDIT LOG : Paiement échoué
    Rails.logger.warn "[AUDIT] Payment failed - PaymentIntent: #{payment_intent['id']}, IP: #{request.remote_ip}"

    order = Order.find_by(stripe_payment_intent_id: payment_intent['id'])

    if order
      order.update(status: 'cancelled')
      order.product.update(sold: false)

      # 📊 AUDIT LOG : Commande annulée suite échec paiement
      Rails.logger.error "[AUDIT] Order cancelled due to payment failure - Order ##{order.id}, Buyer: #{order.buyer.email}, Amount: #{order.total_amount}€"
    end
  end
end
