class ProductsController < ApplicationController

  def show
    @product = Product.find_by(:id => params[:id], :slug => params[:slug])
    return redirect_to '/shop' if @product.nil?
    if @product.end_time < Time.now && !@product.is_users?(current_user)
      Product.expire_products
      flash[:notice] = "Sorry about that, #{@product.title} has already expired."
      return redirect_to '/shop'
    end
    Stripe.api_key = ENV['STRIPE_SECRET_KEY']
    @stripe_customer = Stripe::Customer.retrieve(current_user.retailer.stripe_id) if current_user.is_retailer?
    @company_products = Product.where('wholesaler_id = ? AND status = ? AND id != ?', @product.wholesaler_id, 'live', @product.id).order(current_sales: :desc).limit(3)
    @similar_products = Product.where('category = ? AND status = ? AND id != ?', @product.category, 'live', @product.id).order(current_sales: :desc).limit(3)
  end

  def wholesaler_show
    @product = Product.find(params[:id])
    @products_to_ship = @product.commits.where('shipping_id IS NULL').count
    redirect_to '/shop' if !current_user.is_wholesaler? || current_user.wholesaler.id != @product.wholesaler.id
  end

  def edit
    @product = Product.find(params[:id])
  end

  def update
    product = Product.find(params[:id])
    if product.wholesaler_id == current_user.wholesaler.id
      product.update(product_params)
      if product.save!
        return redirect_to "/product/#{product.id}/#{product.slug}"
      else
        flash[:error] = product.errors.full_messages
        return redirect_to request.referrer
      end
    end
  end

  def create
    product = Product.create(product_params)
    product.wholesaler_id = current_user.wholesaler.id
    if product.goal.nil?
      product.goal = params[:product][:goal]
    end
    if product.save
      # current_products = current_user.products.where('status = live')
      # product.create_uuid
      redirect_to "/approve_product/#{product.id}"
    else
      flash[:error] = product.errors
      redirect_to request.referrer
    end
  end

  def destroy
    product = Product.find(params[:id])
    if product.wholesaler_id == current_user.wholesaler.id
      product.delete
      return redirect_to request.referrer
    end
  end

  def full_price
    @product = Product.where('id in (select product_id from product_tokens where token = ?)', params[:token]).first
    redirect_to "/shop" if @product.status == 'past' || @product.product_token.expiration_datetime <= Time.now
    @company_products = Product.where('wholesaler_id = ? AND status = ? AND id != ?', @product.wholesaler.id, 'live', @product.id).order(current_sales: :desc).limit(3)
    @similar_products = Product.where('category = ? AND status = ? AND id != ?', @product.category, 'live', @product.id).order(current_sales: :desc).limit(3)
  end

  def bluebird_choice
    if params[:query]
      @products = Product.where('slug LIKE ? AND end_time > ? AND status = ?
                                OR LOWER(description) LIKE ? AND end_time > ? AND status = ?
                                OR user_id in (
                                  select id from users where key like ?
                                ) AND end_time > ? AND status = ?',
                                "%#{slug}%", Time.now, 'live',
                                "%#{slug}%", Time.now, 'live',
                                "%#{slug}%", Time.now, 'live').page(params[:page]).per_page(6)
    else
      @products = Product.where('status = ? AND end_time > ? AND featured = ?', 'live', Time.now, true).page(params[:page]).per_page(6)
    end
  end

  private
  def product_params
    params.require(:product).permit(:user_id, :percent_discont, :goal, :company_name, :current_sales,
      :duration, :title, :price, :description, :long_description, :retail_price, :discount, :status, :category, :quantity,
      :feature_one, :feature_two, :feature_three, :feature_four, :feature_five, :minimum_order, :main_image,
      :photo_two, :photo_three, :photo_four, :photo_five)
  end

end
