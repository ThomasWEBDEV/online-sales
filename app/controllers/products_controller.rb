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

    # Produits similaires : logique intelligente
    @similar_products = find_similar_products(@product)
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

  # Logique pour trouver des produits similaires
  def find_similar_products(product)
    # Exclure le produit actuel et les produits vendus
    similar = Product.where.not(id: product.id)
                    .where("sold IS NULL OR sold = false")

    # Stratégie 1 : Même vendeur (priorité)
    same_seller = similar.where(user_id: product.user_id).limit(3)

    # Stratégie 2 : Prix similaire (±30%)
    price_min = product.price * 0.7
    price_max = product.price * 1.3
    similar_price = similar.where(price: price_min..price_max)
                          .where.not(user_id: product.user_id)
                          .order(views_count: :desc)
                          .limit(3)

    # Combiner et limiter à 4 produits
    (same_seller + similar_price).uniq.first(4)
  end
end
