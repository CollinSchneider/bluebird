require 'easypost'
class WholesalersController < ApplicationController
  layout 'wholesaler'
  before_action :redirect_if_not_logged_in, :authenticate_wholesaler

  def approve_product
    @product = Product.find(params[:id])
    redirect_to "/wholesaler/profile" if !current_user.is_admin? && @product.wholesaler_id != current_user.wholesaler.id
  end

  def fix_product
    @product = Product.find_by(:uuid => params[:uuid])
    return redirect_to "/wholesaler/profile" if @product.nil? || (!current_user.is_admin? && @product.wholesaler_id != current_user.wholesaler.id)

    if request.post?
      product = Product.find_by(:uuid => params[:uuid])
      og_percent = product.percent_discount
      product.update(product_params)
      if product.save
        if product.percent_discount != og_percent
          product.skus.each do |sku|
            sku.discount_price = sku.price - (sku.price*(product.percent_discount/100))
            sku.save!
          end
        end
        return redirect_to "/approve_product/#{product.id}"
      else
        flash[:error] = product.errors.full_messages
        return redirect_to request.referrer
      end
    end
  end

  def launch_product
    if request.put?
      @product = Product.find(params[:id])
      @product.set_product_start_data
      flash[:success] = "Product now live!"
      return redirect_to "/products/#{@product.id}/#{@product.slug}"
    end
  end

  def start_over
    product = Product.find_by(:uuid => params[:uuid])
    product.destroy
    return redirect_to "/new_product?duration=#{params[:duration]}&goal=#{params[:goal]}"
  end

  def relist
    @product = Product.find_by_uuid(params[:uuid])
  end

  def current_sales
    if params[:query]
      query = "%#{params[:query].gsub(' ', '').downcase}%"
      @products = current_user.wholesaler.products.where('status = ? AND lower(title) LIKE ? or status = ?
        AND lower(description) LIKE ?', 'live', query, 'live', query
        ).order(end_time: :asc).page(params[:page]).per_page(6)
    else
      @products = current_user.wholesaler.products.where('status = ?', 'live'
        ).order(end_time: :asc).page(params[:page]).per_page(6)
    end
    @title = "Current Sales"
  end

  def past_products
    if params[:query]
      query = "%#{params[:query].gsub(' ', '').downcase}%"
      @products = current_user.wholesaler.products.where('status != ? AND status != ? AND lower(title) LIKE ? OR status != ? AND status != ? AND lower(description) LIKE ?',
        'live', 'needs_attention', query, 'live', 'needs_attention', query).order(end_time: :asc).page(params[:page]).per_page(6)
    else
      @products = current_user.wholesaler.products.where('status != ? AND status != ?', 'live', 'needs_attention').order(end_time: :desc).page(params[:page]).per_page(6)
    end
    @title = "Past Products"
  end

  def needs_attention
    @products = current_user.wholesaler.products.where('status = ?', 'needs_attention')
  end

  def manage_shipping
    EasyPost.api_key = ENV['EASYPOST_API_KEY']
    @users_addresses = []
    current_user.shipping_addresses.each do |address|
      easy_post_address = EasyPost::Address.retrieve(address.address_id)
      @users_addresses.push(easy_post_address)
    end
  end

  def accounts
    Stripe.api_key = ENV['STRIPE_SECRET_KEY']
    if current_user.stripe_credential.present?
      @stripe_customer = Stripe::Account.retrieve(current_user.stripe_credential.stripe_user_id)
    end
  end

  def analytics
    @wholesaler = current_user.wholesaler
    @best_sellers = @wholesaler.products.order(current_sales: :desc)
  end

  def company
    @wholesaler = current_user.wholesaler
    @company = current_user.company
    @title = @company.company_name
    if request.put?
      #
    end
  end

  def bluebird_plus
    Stripe.api_key = ENV['STRIPE_SECRET_KEY']
    @stripe_customer = Stripe::Customer.retrieve(current_user.wholesaler.stripe_customer_id)
  end

  def invite
    if request.post?
      retail_name = params[:invitee_name]
      retail_email = params[:invitee_email]
      referral = ReferralGenerator.new(:user_id => current_user.id, :referred_email => retail_email).perform!
      if !referral[:errors].nil?
        flash[:error] = referral[:errors].join('<br>').html_safe
        return redirect_to request.referrer
      else
        BlueBirdEmail.invite_retailer_email(retail_name, retail_email, current_user, referral[:code])
        flash[:success] = "Referral sent!"
        return redirect_to request.referrer
      end
    end
  end

  def approve
    @products = current_user.wholesaler.pending_products
  end

  def needs_shipping
    return redirect_to '/wholesaler' if !current_user.wholesaler.orders_to_ship.any?
    @retailer_orders = Retailer.all.where("id in (
      select retailer_id from commits where wholesaler_id = ? AND has_shipped = 'f' AND refunded = 'f'
    )", current_user.wholesaler.id)
    @pos_to_ship = current_user.wholesaler.orders_to_ship
    # product_array = current_user.wholesaler.products.where('status = ? OR status = ? OR status = ?', 'goal_met', 'discount_granted', 'full_price').pluck(:id).to_a
    # @need_to_ship = Commit.where('product_id in (?) AND shipping_id IS NULL AND card_declined != ?', product_array, true)

    if !params[:shipment].nil?
      @shipment = Shipping.find_by(:id => params[:shipment])
      return redirect_to "/needs_shipping" if @shipment.nil? || @shipment.wholesaler_id != current_user.wholesaler.id
      EasyPost.api_key = ENV['EASYPOST_API_KEY']
      @ez_shipment = EasyPost::Tracker.retrieve(@shipment.tracking_id)
      @shipments = current_user.wholesaler.orders_to_ship
    end

    respond_to do |format|
      format.html
      format.pdf do
        pdf = AlreadyPrintedPdf.new(current_user)
        send_data pdf.render,
            filename: "BlueBird_#{Time.current.strftime('%B/%d/%Y')}_Order.pdf",
            type: 'application/pdf'
      end
    end
  end

  def already_printed
    respond_to do |format|
      format.pdf do
        pdf = AlreadyPrintedPdf.new(current_user)
        send_data pdf.render,
            filename: "#{Time.current.strftime('%B/%d/%Y')}-Order.pdf",
            type: 'application/pdf'
      end
    end
  end

  def change_password
    if request.put?
      if params[:user][:password] == params[:user][:confirm_password]
        if params[:user][:password].length > 7
          current_user.update(user_password_params)
          flash[:success] = "Password Updated"
        else
          flash[:error] = "Password must be at least 8 characters long."
        end
      else
        flash[:error] = "Password and Password Confirmation must match."
      end
      return redirect_to request.referrer
    end
  end

  private
  def user_password_params
    params.require(:user).permit(:password)
  end

  def product_params
    params.require(:product).permit(:user_id, :percent_discount, :goal, :company_name, :current_sales,
      :duration, :title, :price, :description, :long_description, :retail_price, :discount, :status, :category, :quantity,
      :feature_one, :feature_two, :feature_three, :feature_four, :feature_five, :minimum_order, :main_image,
      :photo_two, :photo_three, :photo_four, :photo_five)
  end

  def authenticate_wholesaler
    return redirect_to '/shop' if current_user.is_retailer?
  end

end
