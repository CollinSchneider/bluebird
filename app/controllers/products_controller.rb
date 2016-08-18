class ProductsController < ApplicationController

  def show
    @product = Product.find(params[:id])
    if Time.now > @product.end_time
      redirect_to shop_path
    end
    @company_products = Product.where('wholesaler_id = ? AND status = ? AND id != ?', @product.wholesaler_id, 'live', @product.id).order(current_sales: :desc).limit(3)
    @similar_products = Product.where('category = ? AND status = ? AND id != ?', @product.category, 'live', @product.id).order(current_sales: :desc).limit(3)
  end

  def wholesaler_show
    @product = Product.find(params[:id])
    @products_to_ship = @product.commits.where('shipping_id IS NULL').count
    # @product.created_at.beginning_of_day..DateTime.now.beginning_of_day do |time|
    # end
    # @total_sales = {}
    # @product.commits.each do |commit|
    # end
    redirect_to '/shop' if !current_user.is_wholesaler? || current_user.wholesaler.id != @product.wholesaler.id
  end

  def edit
    @product = Product.find(params[:id])
    authenticate_wholesaler_product(@product)
  end

  def update
    product = Product.find(params[:id])
    product.update(product_params)
    redirect_to product_path(product.id)
  end

  def create
    product = Product.create(product_params)
    product.wholesaler_id = current_user.wholesaler.id
    if product.goal.nil?
      product.goal = params[:product][:goal]
    end
    if product.save
      # current_products = current_user.products.where('status = live')
      product.create_uuid
      redirect_to "/approve_product/#{product.id}"
    else
      flash[:error] = product.errors
      redirect_to request.referrer
    end
  end

  def destroy
    product = Product.find(params[:id])
    product.delete
    redirect_to request.referrer
  end

  def full_price
    @product = Product.where('id in (select product_id from product_tokens where token = ?)', params[:token]).first
    @company_products = Product.where('user_id = ? AND status = ? AND id != ?', @product.user_id, 'live', @product.id).order(current_sales: :desc).limit(3)
    @similar_products = Product.where('category = ? AND status = ? AND id != ?', @product.category, 'live', @product.id).order(current_sales: :desc).limit(3)
  end

  # def discover
  # end

  private
  def product_params
    params.require(:product).permit(:user_id, :percent_discont, :goal, :company_name, :current_sales,
      :duration, :title, :price, :description, :discount, :status, :category, :quantity, :main_image,
      :photo_two, :photo_three, :photo_four, :photo_five)
  end

end
