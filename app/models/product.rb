class Product < ApplicationRecord
  belongs_to :user
  has_many :orders, dependent: :restrict_with_error
  has_many_attached :photos

  # 🔒 VALIDATIONS STRICTES
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :description, presence: true, length: { minimum: 10, maximum: 1000 }
  validates :price, presence: true, numericality: {
    greater_than: 0,
    less_than_or_equal_to: 1_000_000
  }
  validates :user_id, presence: true

  # 🔒 VALIDATION : Au moins une photo requise
  validate :must_have_at_least_one_photo, on: :create, if: :new_record?

  # 🔒 VALIDATION : Ne peut pas modifier un produit vendu
  validate :cannot_modify_if_sold, on: :update

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

  private

  def must_have_at_least_one_photo
    if new_record? && !photos.attached?
      errors.add(:photos, "Au moins une photo est requise")
    end
  end

  # 🔒 SÉCURITÉ : Empêcher la modification d'un produit vendu
  def cannot_modify_if_sold
    if sold_was && (name_changed? || price_changed? || description_changed?)
      errors.add(:base, "Impossible de modifier un produit vendu")
    end
  end
end
