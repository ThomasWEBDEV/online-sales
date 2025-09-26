class ProductsController < ApplicationController
  include Pundit::Authorization

  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_product, only: [:show, :edit, :update, :destroy, :favorite, :unfavorite]

  def index
    @products = policy_scope(Product)

    # Recherche existante
    if params[:query].present?
      @products = @products.where("name ILIKE ?", "%#{params[:query]}%")
    end

    # Nouveau : Tri
    case params[:sort]
    when 'price_asc'
      @products = @products.order(price: :asc)
    when 'price_desc'
      @products = @products.order(price: :desc)
    when 'popular'
      @products = @products.order(views_count: :desc)
    else
      @products = @products.order(created_at: :desc) # Plus récents par défaut
    end
  end

  def show
    authorize @product
    @product.increment!(:views_count)
  end

  def new
    @product = current_user.products.new
    authorize @product
  end

  def create
    @product = current_user.products.new(product_params)
    authorize @product
    if @product.save
      redirect_to @product, notice: 'Produit créé avec succès.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @product
  end

  def update
    authorize @product
    if @product.update(product_params)
      redirect_to @product, notice: 'Produit mis à jour avec succès.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @product
    @product.destroy
    redirect_to products_path, notice: 'Produit supprimé avec succès.'
  end

  # NOUVELLES ACTIONS POUR LES FAVORIS
  def favorite
    @favorite = current_user.favorites.build(product: @product)
    if @favorite.save
      redirect_back(fallback_location: @product, notice: 'Produit ajouté aux favoris!')
    else
      redirect_back(fallback_location: @product, alert: 'Erreur lors de l\'ajout aux favoris.')
    end
  end

  def unfavorite
    @favorite = current_user.favorites.find_by(product: @product)
    @favorite&.destroy
    redirect_back(fallback_location: @product, notice: 'Produit retiré des favoris!')
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:name, :description, :price, :photo, :sold)
  end
end
