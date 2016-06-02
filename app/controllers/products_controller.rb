class ProductsController < ApplicationController

  def index
    authenticate_anybody
    @products = Product.all
  end

  def show
    @product = Product.find(params[:id])
    @batch_products = Product.where('batch_id = ? AND id != ?', @product.batch_id, @product.id).limit(3)
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
    current_batches = Batch.where('user_id = ? AND status = ?', current_user.id, 'live')
    current_batches.each do |batch|
      batch.products.each do |batch_product|
        if batch_product.title == product.title
          product.delete
          flash[:error] = "You have another batch currently in progress with this product"
        end
      end
    end
    redirect_to request.referrer
  end

  def destroy
    product = Product.find(params[:id])
    product.delete
    redirect_to request.referrer
  end

  private
  def product_params
    params.require(:product).permit(:user_id, :batch_id, :title, :price, :description, :discount, :status, :category, :quantity, :main_image, :photo_two, :photo_three, :photo_four, :photo_five)
  end

end
