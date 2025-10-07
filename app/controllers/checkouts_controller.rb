class CheckoutsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_product, only: [:create]

  def create
    # Vérifier que le produit est disponible
    unless @product.can_be_purchased?
      redirect_to @product, alert: "Ce produit n'est plus disponible."
      return
    end

    # Vérifier que l'acheteur n'est pas le vendeur
    if @product.user == current_user
      redirect_to @product, alert: "Vous ne pouvez pas acheter votre propre produit."
      return
    end

    # Calculer les frais de livraison
    shipping_cost = calculate_shipping_cost(params[:shipping_method] || 'standard')

    # Créer la commande en pending
    @order = Order.new(
      buyer: current_user,
      seller: @product.user,
      product: @product,
      amount: @product.price,
      shipping_cost: shipping_cost,
      shipping_method: params[:shipping_method] || 'standard',
      status: 'pending'
    )

    if @order.save
      # Créer la session Stripe Checkout
      session = create_stripe_session(@order)

      if session
        # Sauvegarder l'ID de session
        @order.update(stripe_session_id: session.id)

        # Rediriger vers Stripe Checkout
        redirect_to session.url, allow_other_host: true
      else
        @order.destroy
        redirect_to @product, alert: "Erreur lors de la création de la session de paiement."
      end
    else
      redirect_to @product, alert: "Erreur lors de la création de la commande."
    end
  end

  def success
    # Page de confirmation après paiement réussi
    session_id = params[:session_id]

    if session_id.present?
      @order = Order.find_by(stripe_session_id: session_id)

      unless @order
        redirect_to root_path, alert: "Commande introuvable."
      end
    else
      redirect_to root_path, alert: "Session invalide."
    end
  end

  def cancel
    # Page si l'utilisateur annule le paiement
    redirect_to root_path, notice: "Paiement annulé. Vous pouvez réessayer quand vous le souhaitez."
  end

  private

  def set_product
    @product = Product.find(params[:product_id])
  end

  def calculate_shipping_cost(method)
    case method
    when 'express' then 9.90
    when 'colissimo' then 7.50
    when 'mondial_relay' then 4.90
    else 5.90 # standard
    end
  end

  def create_stripe_session(order)
    line_items = [
      {
        price_data: {
          currency: 'eur',
          product_data: {
            name: order.product.name,
            description: order.product.description.truncate(500)
          },
          unit_amount: (order.amount * 100).to_i # Stripe utilise les centimes
        },
        quantity: 1
      },
      {
        price_data: {
          currency: 'eur',
          product_data: {
            name: "Frais de livraison (#{order.shipping_method_name})"
          },
          unit_amount: (order.shipping_cost * 100).to_i
        },
        quantity: 1
      }
    ]

    Stripe::Checkout::Session.create(
      payment_method_types: ['card'],
      line_items: line_items,
      mode: 'payment',
      success_url: checkout_success_url(session_id: '{CHECKOUT_SESSION_ID}'),
      cancel_url: checkout_cancel_url,
      customer_email: current_user.email,
      metadata: {
        order_id: order.id
      },
      shipping_address_collection: {
        allowed_countries: ['FR', 'BE', 'CH', 'LU', 'MC']
      }
    )
  rescue Stripe::StripeError => e
    Rails.logger.error "Stripe error: #{e.message}"
    nil
  end
end
