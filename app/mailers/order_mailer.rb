class OrderMailer < ApplicationMailer
  default from: 'marketplace@innovaition.cloud'

  # Email envoyé à l'acheteur après paiement
  def purchase_confirmation(order)
    @order = order
    @buyer = order.buyer
    @product = order.product
    @seller = order.seller

    mail(
      to: @buyer.email,
      subject: "✅ Confirmation d'achat - Commande ##{@order.id}"
    )
  end

  # Email envoyé au vendeur après paiement
  def sale_notification(order)
    @order = order
    @seller = order.seller
    @product = order.product
    @buyer = order.buyer

    mail(
      to: @seller.email,
      subject: "💰 Nouvelle vente - #{@product.name}"
    )
  end

  # Email envoyé à l'acheteur quand vendeur expédie
  def shipping_confirmation(order)
    @order = order
    @buyer = order.buyer
    @product = order.product

    mail(
      to: @buyer.email,
      subject: "📦 Votre commande a été expédiée - ##{@order.id}"
    )
  end
end
