class Product < ApplicationRecord
  belongs_to :user
  has_many :orders, dependent: :restrict_with_error
  has_many_attached :photos

  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :description, presence: true, length: { minimum: 10, maximum: 500 }
  validates :price, presence: true, numericality: { greater_than: 0 }

  # Scopes
  scope :available, -> { where(sold: [false, nil]) }
  scope :sold_out, -> { where(sold: true) }
  scope :recent, -> { order(created_at: :desc) }
  scope :popular, -> { order(views_count: :desc) }

  # Méthodes
  def available?
    !sold
  end

  def can_be_purchased?
    available? && price.present? && price > 0
  end

  # Vérifier si le produit a des commandes
  def has_orders?
    orders.any?
  end

  # Obtenir la commande payée (s'il y en a une)
  def paid_order
    orders.paid.first
  end

  # Méthode helper pour la photo principale
  def main_photo
    photos.first
  end
end
