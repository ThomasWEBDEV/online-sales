class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Associations produits
  has_many :products, dependent: :destroy

  # Associations favoris
  has_many :favorites, dependent: :destroy
  has_many :favorite_products, through: :favorites, source: :product

  # Associations commandes
  has_many :purchases, class_name: 'Order', foreign_key: 'buyer_id', dependent: :destroy
  has_many :sales, class_name: 'Order', foreign_key: 'seller_id', dependent: :destroy

  # Produits achetés
  has_many :purchased_products, through: :purchases, source: :product

  # Méthodes helper favoris
  def has_favorite?(product)
    favorites.exists?(product: product)
  end

  # Méthodes helper commandes
  def total_sales
    sales.paid.sum(:total_amount)
  end

  def total_purchases
    purchases.paid.sum(:total_amount)
  end

  def pending_sales
    sales.where(status: ['paid', 'processing'])
  end

  def active_sales
    sales.where(status: ['paid', 'processing', 'shipped'])
  end

  # Statistiques vendeur
  def seller_stats
    {
      total_sales: sales.paid.count,
      total_revenue: total_sales,
      pending_orders: sales.paid.count,
      to_ship: sales.where(status: 'paid').count,
      shipped: sales.shipped.count,
      completed: sales.delivered.count
    }
  end

  # Statistiques acheteur
  def buyer_stats
    {
      total_purchases: purchases.paid.count,
      total_spent: total_purchases,
      pending_delivery: purchases.where(status: ['paid', 'processing', 'shipped']).count,
      completed: purchases.delivered.count
    }
  end

  # Vérifier si l'utilisateur a acheté un produit
  def purchased?(product)
    purchases.paid.exists?(product: product)
  end
end
