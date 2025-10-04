class CreateOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :orders do |t|
      # Associations
      t.references :buyer, null: false, foreign_key: { to_table: :users }
      t.references :seller, null: false, foreign_key: { to_table: :users }
      t.references :product, null: false, foreign_key: true

      # Paiement Stripe
      t.string :stripe_session_id
      t.string :stripe_payment_intent_id

      # Montants
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.decimal :shipping_cost, precision: 10, scale: 2, default: 0
      t.decimal :total_amount, precision: 10, scale: 2, null: false

      # État de la commande
      t.string :status, default: 'pending', null: false
      # États possibles: pending, paid, processing, shipped, delivered, cancelled, refunded

      # Adresse de livraison
      t.string :shipping_name
      t.string :shipping_address_line1
      t.string :shipping_address_line2
      t.string :shipping_city
      t.string :shipping_postal_code
      t.string :shipping_country, default: 'FR'
      t.string :shipping_phone

      # Méthode de livraison
      t.string :shipping_method, default: 'standard'
      # Méthodes: standard, express, colissimo, mondial_relay

      # Tracking
      t.string :tracking_number
      t.datetime :shipped_at
      t.datetime :delivered_at

      # Notes
      t.text :buyer_notes
      t.text :seller_notes

      t.timestamps
    end

    # Index pour performances
    add_index :orders, :status
    add_index :orders, :stripe_session_id, unique: true
    add_index :orders, :created_at
  end
end
