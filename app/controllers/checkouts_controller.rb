class CheckoutsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_product, only: [:create]

  def create
    unless @product.can_be_purchased?
      redirect_to @product, alert: "Ce produit n'est plus disponible."
      return
    end

    if @product.user == current_user
      redirect_to @product, alert: "Vous ne pouvez pas acheter votre propre produit."
      return
    end

    shipping_cost = calculate_shipping_cost(params[:shipping_method] || 'standard')

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
      Rails.logger.info "✅ Order ##{@order.id} created (pending)"

      session = create_stripe_session(@order)

      if session
        @order.update(stripe_session_id: session.id)
        Rails.logger.info "✅ Stripe session created: #{session.id}"
        Rails.logger.info "📦 Metadata order_id: #{@order.id}"

        # IMPORTANT : Redirection complète forcée vers Stripe
        redirect_to session.url, allow_other_host: true, status: :see_other
      else
        @order.destroy
        redirect_to @product, alert: "Erreur lors de la création de la session de paiement."
      end
    else
      redirect_to @product, alert: "Erreur lors de la création de la commande."
    end
  end

  def success
    session_id = params[:session_id]

    if session_id.present? && session_id != '{CHECKOUT_SESSION_ID}'
      @order = Order.find_by(stripe_session_id: session_id)

      if @order
        render :success
      else
        redirect_to my_purchases_path, notice: "Paiement réussi ! Votre commande est en cours de traitement."
      end
    else
      redirect_to my_purchases_path, notice: "Paiement réussi ! Retrouvez votre commande dans vos achats."
    end
  end

  def cancel
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
    else 5.90
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
          unit_amount: (order.amount * 100).to_i
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
      success_url: my_purchases_url,
      cancel_url: checkout_cancel_url,
      customer_email: current_user.email,
      metadata: {
        order_id: order.id.to_s
      },
      shipping_address_collection: {
        allowed_countries: ['FR', 'BE', 'CH', 'LU', 'MC']
      }
    )
  rescue Stripe::StripeError => e
    Rails.logger.error "❌ Stripe error: #{e.message}"
    nil
  end
end
