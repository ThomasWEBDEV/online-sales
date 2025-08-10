class ProductPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      # Tous les utilisateurs peuvent voir tous les produits
      scope.all
    end
  end

  # Tout le monde peut voir un produit
  def show?
    true
  end

  # Seuls les utilisateurs connectés peuvent créer un produit
  def create?
    user.present?
  end

  # Seul le propriétaire peut modifier son produit
  def update?
    record.user == user
  end

  # Seul le propriétaire peut supprimer son produit
  def destroy?
    record.user == user
  end
end
