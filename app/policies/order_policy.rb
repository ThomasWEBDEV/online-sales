class OrderPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      # Un utilisateur peut voir ses achats et ses ventes
      scope.where(buyer_id: user.id).or(scope.where(seller_id: user.id))
    end
  end

  # Voir une commande : acheteur OU vendeur
  def show?
    record.buyer == user || record.seller == user
  end

  # Créer une commande : utilisateur connecté
  def create?
    user.present?
  end

  # Modifier une commande : UNIQUEMENT le vendeur peut marquer comme expédié
  def update?
    record.seller == user
  end

  # Annuler une commande : acheteur OU vendeur (selon conditions)
  def cancel?
    (record.buyer == user || record.seller == user) && record.can_be_cancelled?
  end

  # Marquer comme expédié : UNIQUEMENT le vendeur
  def mark_as_shipped?
    record.seller == user && record.can_be_shipped?
  end
end
