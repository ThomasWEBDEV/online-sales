class Order < ApplicationRecord
  # Associations
  belongs_to :buyer, class_name: 'User'
  belongs_to :seller, class_name: 'User'
  belongs_to :product

  # Validations
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :total_amount, presence: true, numericality: { greater_than: 0 }
  validates :status, presence: true, inclusion: {
    in: %w[pending paid processing shipped delivered cancelled refunded]
  }
  validates :shipping_name, presence: true, if: :paid?
  validates :shipping_address_line1, presence: true, if: :paid?
  validates :shipping_city, presence: true, if: :paid?
  validates :shipping_postal_code, presence: true, if: :paid?
  validates :shipping_phone, presence: true, if: :paid?

  # Scopes
  scope :pending, -> { where(status: 'pending') }
  scope :paid, -> { where(status: 'paid') }
  scope :processing, -> { where(status: 'processing') }
  scope :shipped, -> { where(status: 'shipped') }
  scope :delivered, -> { where(status: 'delivered') }
  scope :recent, -> { order(created_at: :desc) }

  # Callbacks
  before_validation :calculate_total, if: :new_record?
  after_create :mark_product_as_sold, if: :paid?

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
    # Ici on pourrait envoyer un email au buyer
    OrderMailer.shipped_notification(self).deliver_later
  end

  def mark_as_delivered!
    update!(status: 'delivered', delivered_at: Time.current)
    OrderMailer.delivered_notification(self).deliver_later
  end

  def cancel!
    return unless pending? || paid?

    update!(status: 'cancelled')
    product.update!(sold: false) if product.sold?

    # Si déjà payé, initier un remboursement
    initiate_refund if paid?
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

  private

  def calculate_total
    self.total_amount = amount + (shipping_cost || 0)
  end

  def mark_product_as_sold
    product.update!(sold: true)
  end

  def initiate_refund
    # Logique de remboursement Stripe à implémenter
    Stripe::Refund.create(payment_intent: stripe_payment_intent_id)
    update!(status: 'refunded')
  rescue Stripe::StripeError => e
    Rails.logger.error "Refund failed: #{e.message}"
  end
end
