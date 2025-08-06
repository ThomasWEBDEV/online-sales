class ProductsController < ApplicationController
    before_action :authenticate_user!, except: [:index, :show]

    def index
      @products = Product.all
    end

    def show
      @product = Product.find(params[:id])
    end

    def new
      @product = current_user.products.new
    end

    def create
      @product = current_user.products.new(product_params)
      if @product.save
        redirect_to @product
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @product = current_user.products.find(params[:id])
    end

    def update
      @product = current_user.products.find(params[:id])
      if @product.update(product_params)
        redirect_to @product
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @product = current_user.products.find(params[:id])
      @product.destroy
      redirect_to products_path
    end

    private

    def product_params
      params.require(:product).permit(:name, :description, :price)
    end
  end
end
