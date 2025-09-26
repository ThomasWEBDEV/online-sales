class CreateFavorites < ActiveRecord::Migration[7.1]
  def change
    create_table :favorites do |t|
      t.references :user, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true

      t.timestamps
    end

    # Empêcher qu'un utilisateur ajoute 2 fois le même produit en favori
    add_index :favorites, [:user_id, :product_id], unique: true
  end
end
