class AddIndexesToProductsForSearch < ActiveRecord::Migration[7.1]
  def change
    add_index :products, :sold
    add_index :products, :price
    add_index :products, :created_at
    add_index :products, [:user_id, :sold]
  end
end
