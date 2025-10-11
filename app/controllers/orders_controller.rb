class OrdersController < ApplicationController
  include Pundit::Authorization

  before_action :authenticate_user!
  before_action :set_order, only: [:show, :mark_as_shipped, :cancel]

  # Liste des achats - SANS les annulées
  def purchases
    @orders = current_user.purchases
                          .where.not(status: ['pending', 'cancelled'])
                          .recent
    @stats = current_user.buyer_stats
  end

  # Liste des ventes - SANS les annulées
  def sales
    @orders = current_user.sales
                          .where.not(status: ['pending', 'cancelled'])
                          .recent
    @stats = current_user.seller_stats
  end

  # Détail d'une commande
  def show
    authorize @order
  end

  # Marquer comme expédié (vendeur uniquement)
  def mark_as_shipped
    authorize @order, :mark_as_shipped?

    if @order.mark_as_shipped!(params[:tracking_number])
      redirect_to order_path(@order), notice: "Commande marquée comme expédiée !"
    else
      redirect_to order_path(@order), alert: "Erreur lors de la mise à jour."
    end
  end

  # Annuler une commande
  def cancel
    authorize @order, :cancel?

    if @order.cancel!
      redirect_to my_purchases_path, notice: "Commande annulée avec succès."
    else
      redirect_to order_path(@order), alert: "Impossible d'annuler cette commande."
    end
  end

  private

  def set_order
    @order = Order.find(params[:id])
  end
end
