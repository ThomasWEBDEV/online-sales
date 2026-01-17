class Product < ApplicationRecord
  attr_accessor :skip_photo_validation

  belongs_to :user
  has_many :orders, dependent: :restrict_with_error
  has_many_attached :photos

  # VALIDATIONS STRICTES
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :description, presence: true, length: { minimum: 10, maximum: 1000 }
  validates :price, presence: true, numericality: {
    greater_than: 0,
    less_than_or_equal_to: 1_000_000
  }
  validates :user_id, presence: true

  # VALIDATION : Au moins une photo requise (sauf si skip activé)
  validate :must_have_at_least_one_photo, on: :create, if: -> { new_record? && !skip_photo_validation }

  # VALIDATION : Taille et type des fichiers uploadés
  validate :validate_photo_size
  validate :validate_photo_content_type
  validate :validate_photos_count

  # VALIDATION : Ne peut pas modifier un produit vendu
  validate :cannot_modify_if_sold, on: :update

  # Scopes
  scope :available, -> { where(sold: [false, nil]) }
  scope :sold_out, -> { where(sold: true) }
  scope :recent, -> { order(created_at: :desc) }
  scope :popular, -> { order(views_count: :desc) }

  # Méthodes
  def available?
    !sold
  end

  def can_be_purchased?
    available? && price.present? && price > 0
  end

  # Vérifier si le produit a des commandes
  def has_orders?
    orders.any?
  end

  # Obtenir la commande payée (s'il y en a une)
  def paid_order
    orders.paid.first
  end

  # Méthode helper pour la photo principale
  def main_photo
    photos.first
  end

  private

  def must_have_at_least_one_photo
    unless photos.attached?
      errors.add(:photos, "Au moins une photo est requise")
    end
  end

  # SÉCURITÉ : Valider la taille des photos (max 5 MB par photo)
  def validate_photo_size
    photos.each do |photo|
      if photo.blob&.byte_size && photo.blob.byte_size > 5.megabytes
        errors.add(:photos, "La taille de #{photo.filename} dépasse 5 MB")
      end
    end
  end

  # SÉCURITÉ : Valider le type de contenu (images uniquement)
  def validate_photo_content_type
    acceptable_types = ["image/jpeg", "image/jpg", "image/png", "image/gif", "image/webp"]

    photos.each do |photo|
      unless photo.blob&.content_type.in?(acceptable_types)
        errors.add(:photos, "#{photo.filename} doit être une image (JPEG, PNG, GIF, WebP)")
      end
    end
  end

  # SÉCURITÉ : Valider le contenu RÉEL du fichier (magic bytes)
# SÉCURITÉ : Valider le contenu RÉEL du fichier (magic bytes)
def validate_photo_actual_content
  photos.each do |photo|
    next unless photo.blob

    begin
      # Télécharger temporairement le fichier pour lire les magic bytes
      photo.blob.download do |file_content|
        # Lire les premiers octets du fichier
        magic_bytes = file_content[0, 12]

        # DEBUG : Logger les magic bytes
        Rails.logger.info "[DEBUG] File: #{photo.filename}, Magic bytes: #{magic_bytes.bytes.map { |b| '%02X' % b }.join(' ')}"

        # Signatures de fichiers images valides (magic bytes)
        valid_signatures = [
          "\xFF\xD8\xFF".force_encoding('ASCII-8BIT'),                    # JPEG
          "\x89PNG\r\n\x1A\n".force_encoding('ASCII-8BIT'),               # PNG
          "GIF87a".force_encoding('ASCII-8BIT'),                          # GIF
          "GIF89a".force_encoding('ASCII-8BIT'),                          # GIF
          "RIFF".force_encoding('ASCII-8BIT')                             # WebP (commence par RIFF)
        ]

        is_valid = valid_signatures.any? { |sig| magic_bytes.start_with?(sig) }

        unless is_valid
          # AUDIT LOG : Tentative upload fichier malveillant
          Rails.logger.error "[SECURITY] Malicious file upload attempt - Filename: #{photo.filename}, Content-Type: #{photo.blob.content_type}, User: #{user&.id}"

          errors.add(:photos, "#{photo.filename} n'est pas une image valide")
        end
      end
    rescue => e
      Rails.logger.error "[SECURITY] File validation error - #{e.message}"
      errors.add(:photos, "Erreur lors de la validation de #{photo.filename}")
    end
  end
end

  # SÉCURITÉ : Limiter le nombre de photos (max 10)
  def validate_photos_count
    if photos.length > 10
      errors.add(:photos, "Vous ne pouvez pas uploader plus de 10 photos")
    end
  end

  # SÉCURITÉ : Empêcher la modification d'un produit vendu
  def cannot_modify_if_sold
    if sold_was && (name_changed? || price_changed? || description_changed?)
      errors.add(:base, "Impossible de modifier un produit vendu")
    end
  end
end
