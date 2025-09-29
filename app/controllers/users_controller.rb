class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    @products = @user.products.order(created_at: :desc)
    @products_count = @products.count
    @available_products = @products.where(sold: false)
    @sold_products = @products.where(sold: true)
  end
end
