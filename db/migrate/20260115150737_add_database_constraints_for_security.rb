class AddDatabaseConstraintsForSecurity < ActiveRecord::Migration[7.1]
  def change
    # PRODUCTS : Contraintes de sécurité
    change_column_null :products, :name, false
    change_column_null :products, :description, false
    change_column_null :products, :price, false
    change_column_null :products, :user_id, false

    # Contrainte CHECK : prix positif
    execute <<-SQL
      ALTER TABLE products
      ADD CONSTRAINT check_products_price_positive
      CHECK (price > 0);
    SQL

    # Contrainte CHECK : prix maximum
    execute <<-SQL
      ALTER TABLE products
      ADD CONSTRAINT check_products_price_max
      CHECK (price <= 1000000);
    SQL

    # ORDERS : Contraintes de sécurité
    change_column_null :orders, :buyer_id, false
    change_column_null :orders, :seller_id, false
    change_column_null :orders, :product_id, false
    change_column_null :orders, :amount, false
    change_column_null :orders, :status, false

    # Contrainte CHECK : montant positif
    execute <<-SQL
      ALTER TABLE orders
      ADD CONSTRAINT check_orders_amount_positive
      CHECK (amount > 0);
    SQL

    # Contrainte CHECK : montant maximum
    execute <<-SQL
      ALTER TABLE orders
      ADD CONSTRAINT check_orders_amount_max
      CHECK (amount <= 1000000);
    SQL

    # USERS : Contraintes de sécurité
    change_column_null :users, :email, false

    # Index unique sur email (case-insensitive)
    execute <<-SQL
      CREATE UNIQUE INDEX index_users_on_lower_email
      ON users (LOWER(email));
    SQL
  end
end
