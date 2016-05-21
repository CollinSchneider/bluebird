class ProductsController < ApplicationController

  def index
    authenticate_anybody
    @products = Product.all
  end

  def show
    @product = Product.find(params[:id])
  end

  def edit
    @product = Product.find(params[:id])
    authenticate_wholesaler_product(@product)
  end

  def update
    product = Product.find(params[:id])
    product.update(product_params)
    redirect_to batch_product_path(product.batch_id, product.id)
    # redirect_to product_path(product.id)
  end

  def create
    product = Product.create(product_params)
    redirect_to request.referrer
  end

  def destroy
    product = Product.find(params[:id])
    product.delete
    redirect_to request.referrer
  end

  private
  def product_params
    params.require(:product).permit(:user_id, :batch_id, :title, :price, :description, :discount, :quantity, :status)
  end

end
