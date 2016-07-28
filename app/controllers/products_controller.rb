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
    redirect_to product_path(product.id)
    # redirect_to batch_product_path(product.batch_id, product.id)
  end

  def create
    product = Product.create(product_params)
    product.user_id = current_user.id
    product.status = 'live'
    if product.duration == '1_day'
      product.end_time = (Time.now + 1.hour).beginning_of_hour + 1.day
    elsif product.duration == '7_days'
      product.end_time = (Time.now + 1.hour).beginning_of_hour + 7.days
    elsif product.duration == '10_days'
      product.end_time = (Time.now + 1.hour).beginning_of_hour + 10.days
    elsif product.duration == '14_days'
      product.end_time = (Time.now + 1.hour).beginning_of_hour + 14.days
    elsif product.duration == '30_days'
      product.end_time = (Time.now + 1.hour).beginning_of_hour + 30.days
    elsif product.duration = '5_minutes'
      product.end_time = (Time.now + 2.minutes)
    end
    product.save
    Milestone.create(:goal => params[:product][:goal], :product_id => product.id)
    current_products = current_user.products.where('status = live')
    redirect_to product_path(product.id)
  end

  def destroy
    product = Product.find(params[:id])
    product.delete
    redirect_to request.referrer
  end

  private
  def product_params
    params.require(:product).permit(:user_id, :duration, :title, :price, :description, :discount, :status, :category, :quantity, :main_image, :photo_two, :photo_three, :photo_four, :photo_five)
  end

end
