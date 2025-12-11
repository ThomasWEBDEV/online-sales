class ChangeProductPhotoToPhotos < ActiveRecord::Migration[7.1]
  def up
    # Cette migration ne nécessite aucune modification de la base de données
    # Active Storage gère automatiquement le changement de has_one_attached à has_many_attached
    # Les photos existantes seront automatiquement migrées
  end

  def down
    # Pas de rollback nécessaire
  end
end
