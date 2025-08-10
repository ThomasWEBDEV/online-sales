require 'rails_helper'

RSpec.describe Product, type: :model do
  it 'peut créer un produit valide' do
    user = User.create!(email: 'test@test.com', password: '123456')
    product = Product.create!(
      name: 'iPhone',
      description: 'Un super téléphone',
      price: 999,
      user: user
    )
    expect(product).to be_valid
  end
end
