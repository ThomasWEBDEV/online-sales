class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :products, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :favorite_products, through: :favorites, source: :product

  # Méthode helper pour savoir si un produit est en favori
  def has_favorite?(product)
    favorites.exists?(product: product)
  end
end
