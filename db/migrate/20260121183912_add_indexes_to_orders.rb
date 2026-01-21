class AddIndexesToOrders < ActiveRecord::Migration[7.1]
  def change
    add_index :orders, :status
    add_index :orders, :created_at
    add_index :orders, [:buyer_id, :status]
    add_index :orders, [:seller_id, :status]
    add_index :orders, :stripe_payment_intent_id, unique: true
  end
end
