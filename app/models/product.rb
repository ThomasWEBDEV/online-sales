class Product < ApplicationRecord
  belongs_to :user

  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :description, presence: true, length: { minimum: 10, maximum: 500 }
  validates :price, presence: true, numericality: { greater_than: 0 }
end
