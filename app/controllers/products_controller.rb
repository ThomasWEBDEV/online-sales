class ProductsController < ApplicationController
  include Pundit::Authorization

  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_product, only: [:show, :edit, :update, :destroy]

  def index
    @products = policy_scope(Product)

    # Recherche par nom
    if params[:query].present?
      @products = @products.where("name ILIKE ?", "%#{params[:query]}%")
    end

    # Filtres de prix
    if params[:min_price].present?
      @products = @products.where("price >= ?", params[:min_price])
    end

    if params[:max_price].present?
      @products = @products.where("price <= ?", params[:max_price])
    end

    # Filtre par statut
    case params[:status]
    when 'available'
      @products = @products.where(sold: [false, nil])
    when 'sold'
      @products = @products.where(sold: true)
    end

    # Tri
    case params[:sort]
    when 'price_asc'
      @products = @products.order(price: :asc)
    when 'price_desc'
      @products = @products.order(price: :desc)
    when 'popular'
      @products = @products.order(views_count: :desc)
    else
      @products = @products.order(created_at: :desc)
    end

    @products = @products.limit(12)
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

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:name, :description, :price, :photo, :sold)
  end
end
