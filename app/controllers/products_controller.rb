class ProductsController < ApplicationController
  include Pundit::Authorization

  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_product, only: [:show, :edit, :update, :destroy, :favorite, :unfavorite]

  # SÉCURITÉ : Gestion des erreurs Pundit
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def index
    @products = policy_scope(Product)

    # SÉCURITÉ : Sanitize search query pour éviter injection SQL
    if params[:query].present?
      sanitized_query = ActiveRecord::Base.sanitize_sql_like(params[:query])
      @products = @products.where("name ILIKE ? OR description ILIKE ?", "%#{sanitized_query}%", "%#{sanitized_query}%")
    end

    # Filtres prix avec validation
    if params[:min_price].present? && params[:min_price].to_f >= 0
      @products = @products.where("price >= ?", params[:min_price].to_f)
    end

    if params[:max_price].present? && params[:max_price].to_f >= 0
      @products = @products.where("price <= ?", params[:max_price].to_f)
    end

    # Filtre statut
    if params[:status].present?
      case params[:status]
      when 'available'
        @products = @products.where("sold IS NULL OR sold = false")
      when 'sold'
        @products = @products.where(sold: true)
      end
    end

    # Tri (whitelist des valeurs autorisées)
    allowed_sorts = %w[price_asc price_desc popular recent]
    sort_param = allowed_sorts.include?(params[:sort]) ? params[:sort] : 'recent'

    case sort_param
    when 'price_asc'
      @products = @products.order(price: :asc)
    when 'price_desc'
      @products = @products.order(price: :desc)
    when 'popular'
      @products = @products.order(views_count: :desc)
    else
      @products = @products.order(created_at: :desc)
    end

    # PAGINATION avec params
    @pagy, @products = pagy(@products, items: 24, params: {
      query: params[:query],
      min_price: params[:min_price],
      max_price: params[:max_price],
      status: params[:status],
      sort: params[:sort]
    }.compact)
  end

  def show
    authorize @product
    # SÉCURITÉ : Utilise update_column pour éviter callbacks et validations
    @product.update_column(:views_count, (@product.views_count || 0) + 1)
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
      # AUDIT LOG : Création de produit
      Rails.logger.info "[AUDIT] Product created - ID: #{@product.id}, User: #{current_user.id} (#{current_user.email}), Name: '#{@product.name}', Price: #{@product.price}€, IP: #{request.remote_ip}"

      redirect_to @product, notice: 'Produit créé avec succès.'
    else
      # ⚠️ AUDIT LOG : Échec création
      Rails.logger.warn "[AUDIT] Product creation failed - User: #{current_user.id} (#{current_user.email}), Errors: #{@product.errors.full_messages.join(', ')}, IP: #{request.remote_ip}"

      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @product
  end

  def update
    authorize @product

    # SÉCURITÉ : Empêcher la modification du user_id
    if product_params[:user_id].present? && product_params[:user_id] != @product.user_id
      # AUDIT LOG : Tentative modification user_id
      Rails.logger.error "[SECURITY] Unauthorized user_id modification attempt - Product: #{@product.id}, User: #{current_user.id} (#{current_user.email}), IP: #{request.remote_ip}"

      redirect_to @product, alert: 'Action non autorisée.'
      return
    end

    # Sauvegarder les anciennes valeurs pour le log
    old_price = @product.price
    old_name = @product.name

    if @product.update(product_params)
      # AUDIT LOG : Mise à jour produit
      changes = []
      changes << "Price: #{old_price}€ → #{@product.price}€" if old_price != @product.price
      changes << "Name: '#{old_name}' → '#{@product.name}'" if old_name != @product.name

      Rails.logger.info "[AUDIT] Product updated - ID: #{@product.id}, User: #{current_user.id} (#{current_user.email}), Changes: #{changes.join(', ')}, IP: #{request.remote_ip}"

      redirect_to @product, notice: 'Produit mis à jour avec succès.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @product

    # SÉCURITÉ : Vérifier qu'il n'y a pas de commandes avant suppression
    if @product.has_orders?
      # AUDIT LOG : Tentative suppression produit avec commandes
      Rails.logger.warn "[AUDIT] Product deletion blocked (has orders) - Product: #{@product.id}, User: #{current_user.id} (#{current_user.email}), IP: #{request.remote_ip}"

      redirect_to @product, alert: 'Impossible de supprimer un produit avec des commandes.'
      return
    end

    # Sauvegarder les infos avant destruction
    product_id = @product.id
    product_name = @product.name
    product_price = @product.price

    @product.destroy

    # AUDIT LOG : Suppression produit
    Rails.logger.info "[AUDIT] Product deleted - ID: #{product_id}, Name: '#{product_name}', Price: #{product_price}€, User: #{current_user.id} (#{current_user.email}), IP: #{request.remote_ip}"

    redirect_to products_path, notice: 'Produit supprimé avec succès.'
  end

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
  rescue ActiveRecord::RecordNotFound
    redirect_to products_path, alert: 'Produit introuvable.'
  end

  # SÉCURITÉ : Strong parameters - photos pluriel car has_many_attached
  def product_params
    params.require(:product).permit(:name, :description, :price, :sold, photos: []).tap do |whitelisted|
      # Sanitize name et description pour éviter injections
      whitelisted[:name] = ActionController::Base.helpers.sanitize(whitelisted[:name]) if whitelisted[:name]
      whitelisted[:description] = ActionController::Base.helpers.sanitize(whitelisted[:description]) if whitelisted[:description]
    end
  end

  # SÉCURITÉ : Gestion erreur Pundit
  def user_not_authorized
    # AUDIT LOG : Tentative accès non autorisé
    Rails.logger.warn "[SECURITY] Unauthorized access attempt - User: #{current_user&.id || 'Guest'} (#{current_user&.email || 'N/A'}), Action: #{action_name}, Product: #{@product&.id}, IP: #{request.remote_ip}"

    flash[:alert] = "Vous n'êtes pas autorisé à effectuer cette action."
    redirect_back(fallback_location: root_path)
  end

  def find_similar_products(product)
    similar = Product.where.not(id: product.id)
                    .where("sold IS NULL OR sold = false")

    same_seller = similar.where(user_id: product.user_id).limit(3)

    price_min = product.price * 0.7
    price_max = product.price * 1.3
    similar_price = similar.where(price: price_min..price_max)
                          .where.not(user_id: product.user_id)
                          .order(views_count: :desc)
                          .limit(3)

    (same_seller + similar_price).uniq.first(4)
  end
end
