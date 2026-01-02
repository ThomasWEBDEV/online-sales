class Order < ApplicationRecord
  # Associations
  belongs_to :buyer, class_name: 'User'
  belongs_to :seller, class_name: 'User'
  belongs_to :product

  # 🔒 VALIDATIONS STRICTES
  validates :amount, presence: true, numericality: {
    greater_than: 0,
    less_than_or_equal_to: 1_000_000
  }
  validates :total_amount, presence: true, numericality: {
    greater_than: 0,
    less_than_or_equal_to: 1_000_000
  }
  validates :shipping_cost, numericality: {
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: 10_000,
    allow_nil: true
  }
  validates :status, presence: true, inclusion: {
    in: %w[pending paid processing shipped delivered cancelled refunded]
  }

  # 🔒 VALIDATION : Buyer et Seller doivent être différents
  validate :buyer_and_seller_must_be_different

  # 🔒 VALIDATION : Produit ne peut pas déjà être vendu
  validate :product_must_be_available, on: :create

  # 🔒 VALIDATION : Montant doit correspondre au prix du produit
  validate :amount_matches_product_price, on: :create

  # 🔒 VALIDATION : Changement de statut cohérent
  validate :status_transition_is_valid, on: :update, if: :status_changed?

  # Scopes
  scope :pending, -> { where(status: 'pending') }
  scope :paid, -> { where(status: 'paid') }
  scope :processing, -> { where(status: 'processing') }
  scope :shipped, -> { where(status: 'shipped') }
  scope :delivered, -> { where(status: 'delivered') }
  scope :recent, -> { order(created_at: :desc) }

  # Callbacks
  before_validation :calculate_total, if: :new_record?

  # États
  def pending?
    status == 'pending'
  end

  def paid?
    status == 'paid'
  end

  def processing?
    status == 'processing'
  end

  def shipped?
    status == 'shipped'
  end

  def delivered?
    status == 'delivered'
  end

  def cancelled?
    status == 'cancelled'
  end

  # Actions sur les états
  def mark_as_paid!
    update!(status: 'paid')
    product.update!(sold: true)
  end

  def mark_as_processing!
    update!(status: 'processing')
  end

  def mark_as_shipped!(tracking_number = nil)
    update!(
      status: 'shipped',
      shipped_at: Time.current,
      tracking_number: tracking_number
    )
  end

  def mark_as_delivered!
    update!(status: 'delivered', delivered_at: Time.current)
  end

  def cancel!
    return false unless can_be_cancelled?

    transaction do
      update!(status: 'cancelled')
      product.update!(sold: false) if product.sold?
      # Si déjà payé, initier un remboursement
      initiate_refund if paid?
    end
    true
  rescue => e
    Rails.logger.error "Erreur annulation: #{e.message}"
    false
  end

  # Méthodes helper
  def shipping_address
    [
      shipping_address_line1,
      shipping_address_line2,
      shipping_postal_code,
      shipping_city,
      shipping_country
    ].compact.join(', ')
  end

  def shipping_method_name
    case shipping_method
    when 'standard' then 'Livraison Standard (5-7 jours)'
    when 'express' then 'Livraison Express (2-3 jours)'
    when 'colissimo' then 'Colissimo Suivi'
    when 'mondial_relay' then 'Mondial Relay'
    else 'Non spécifié'
    end
  end

  def can_be_shipped?
    paid? || processing?
  end

  def can_be_cancelled?
    pending? || (paid? && !shipped?)
  end

  def has_complete_address?
    shipping_name.present? &&
      shipping_address_line1.present? &&
      shipping_city.present? &&
      shipping_postal_code.present?
  end

  private

  def calculate_total
    self.total_amount = amount + (shipping_cost || 0)
  end

  def initiate_refund
    Stripe::Refund.create(payment_intent: stripe_payment_intent_id)
    update!(status: 'refunded')
  rescue Stripe::StripeError => e
    Rails.logger.error "Refund failed: #{e.message}"
  end

  # 🔒 SÉCURITÉ : Empêcher qu'un user achète son propre produit
  def buyer_and_seller_must_be_different
    if buyer_id == seller_id
      errors.add(:base, "Vous ne pouvez pas acheter votre propre produit")
    end
  end

  # 🔒 SÉCURITÉ : Vérifier que le produit est disponible
  def product_must_be_available
    if product&.sold?
      errors.add(:product, "n'est plus disponible à la vente")
    end
  end

  # 🔒 SÉCURITÉ : Vérifier que le montant correspond au prix
  def amount_matches_product_price
    if product && amount != product.price
      errors.add(:amount, "ne correspond pas au prix du produit")
    end
  end

  # 🔒 SÉCURITÉ : Transitions de statut cohérentes
  def status_transition_is_valid
    valid_transitions = {
      'pending' => %w[paid cancelled],
      'paid' => %w[processing cancelled refunded],
      'processing' => %w[shipped cancelled],
      'shipped' => %w[delivered],
      'delivered' => [],
      'cancelled' => [],
      'refunded' => []
    }

    old_status = status_was
    new_status = status

    if old_status && !valid_transitions[old_status]&.include?(new_status)
      errors.add(:status, "transition invalide de #{old_status} vers #{new_status}")
    end
  end
end
