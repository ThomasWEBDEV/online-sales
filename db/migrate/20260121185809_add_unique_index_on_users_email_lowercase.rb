class AddUniqueIndexOnUsersEmailLowercase < ActiveRecord::Migration[7.1]
  def up
    # Supprimer l'ancien index s'il existe
    remove_index :users, :email if index_exists?(:users, :email)

    # Créer index unique case-insensitive seulement s'il n'existe pas déjà
    execute "CREATE UNIQUE INDEX IF NOT EXISTS index_users_on_lower_email ON users (LOWER(email));"
  end

  def down
    execute "DROP INDEX IF EXISTS index_users_on_lower_email;"
    add_index :users, :email, unique: true unless index_exists?(:users, :email)
  end
end
