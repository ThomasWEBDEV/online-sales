class FavoritesController < ApplicationController
  include Pundit::Authorization

  before_action :authenticate_user!

  def index
    @favorites = current_user.favorites.includes(:product)
    @products = @favorites.map(&:product)
  end
end
