require 'easypost'
class RetailersController < ApplicationController
  before_action :redirect_if_not_logged_in, :authenticate_retailer
  layout 'retailer'

  def index
    return redirect_to "/retailer/#{current_user.retailer.declined_order}/card_declined" if current_user.retailer.card_declined?
    # @product = current_user.retailer.commits.where(:status => ['live', 'pending'], :full_price => [false, nil])
    @products = Product.where("id in (
      select product_id from commits where retailer_id = ? AND (status = ? OR status = ?) AND full_price = 'f'
    )", current_user.retailer.id, 'live', 'pending')
  end

  def order
    @product = Product.find_by(:id => params[:id], :slug => params[:slug])
    @title = "#{@product.title} Order"
    if params[:edit] == 'true'
      @commit = current_user.retailer.commits.find_by(:product_id => @product.id)
      redirect_to "/products/#{@product.id}/#{@product.slug}/order" if @commit.nil?
    else
      @commit = Commit.new
    end
    # return redirect_to shipping_commit_path(commit.id) if !commit.nil?
    # return redirect_to "/shop" if @product.nil?
    # return redirect_to "/retailer/order_history/#{@commit.id}" if !@commit.nil?
  end

  def full_price_order
    @product = Product.where('id in (select product_id from product_tokens where token = ?) AND slug = ?', params[:token], params[:slug]).first
    return redirect_to "/shop" if @product.status == 'past' || @product.status == 'live' || @product.product_token.expiration_datetime <= Time.current

    commit = current_user.retailer.commits.where("product_id = ? AND full_price = 't'", @product.id)
    return redirect_to "/retailer/order_history/sale_made/#{commit.first.id}" if !commit.empty?
  end

  def ratings
    return redirect_to "/retailer" if current_user.retailer.pending_ratings.empty?
  end

  def order_history
    if params[:query]
      query = params[:query]
      slug = query.downcase
      slug.gsub!(',' '')
      slug.gsub!("'", "")
      slug.gsub!('.', '')
      slug.gsub!(' ', '-')
      slug.gsub!('?', '')
      slug.gsub!('!', '')
      @past_orders = current_user.retailer.commits.where('uuid like ? OR number like ? OR product_id in (
        select id from products where slug LIKE ? OR LOWER(short_description) LIKE ? OR LOWER(long_description) like ? OR wholesaler_id in (
          select id from wholesalers where user_id in (
            select user_id from companies where company_key LIKE ?
          )
        )
      )', "%#{slug}%", "%#{slug}%", "%#{slug}%", "%#{slug}%", "%#{slug}%", "%#{slug}%"
      ).order(created_at: :desc).page(params[:page]).per_page(9)
    else
      @past_orders = current_user.retailer.commits.order(created_at: :desc).page(params[:page]).per_page(9)
    end
    @title = "Past Orders"
  end

  def show_order_history
    @order = Commit.find_by(:id => params[:id])
    return redirect_to "/shop" if @order.nil?
    return redirect_to "/retailer/pending_orders" if @order.retailer.id != current_user.retailer.id
    @title = "#{@order.product.title} Order"
    Stripe.api_key = ENV['STRIPE_SECRET_KEY']
    @stripe_customer = Stripe::Customer.retrieve(@order.retailer.stripe_id)
    @commit_card = @stripe_customer.sources.retrieve(@order.card_id)
  end

  def show_order_not_reached
    @order = Commit.find(params[:id])
    @title = "#{@order.product.title} Order"
    return redirect_to "/retailer/order_history" if (@order.status != 'pending' && @order.status != 'past') || (@order.retailer_id != current_user.retailer.id)
  end

  def show_order_sale_made
    @order = Commit.find(params[:id])
    @title = "#{@order.product.title} Order"
    return redirect_to "/retailer/order_history" if !@order.sale_made || @order.retailer_id != current_user.retailer.id
    if !@order.shipping.nil?
      EasyPost.api_key = ENV['EASYPOST_API_KEY']
      @shipping_info = EasyPost::Tracker.retrieve(@order.shipping.tracking_id)
    end
  end

  def accounts
    Stripe.api_key = ENV['STRIPE_SECRET_KEY']
    @stripe_customer = Stripe::Customer.retrieve(current_user.retailer.stripe_id)
    if @stripe_customer.default_source
      @default_card = @stripe_customer.sources.retrieve(@stripe_customer.default_source)
    end
  end

  def change_password
    if request.put?
      if current_user.authenticate(params[:old_password])
        if params[:user][:password] == params[:user][:password_confirmation]
          if params[:user][:password].length > 7
            current_user.update(user_password_params)
            if current_user.save(validate: false)
              flash[:success] = "Password Updated"
              return redirect_to request.referrer
            end
          else
            flash[:error] = "Password must be at least 8 characters long."
            return redirect_to request.referrer
          end
        else
          flash[:error] = "Password and Password Confirmation do not match."
          return redirect_to request.referrer
        end
      else
        flash[:error] = "Incorrect original password."
      end
    end
  end

  def card_declined
    @commit = Commit.find(params[:order_id])
    return redirect_to '/retailer' if @commit.retailer_id != current_user.retailer.id || !@commit.retailer.card_declined?
    Stripe.api_key = ENV['STRIPE_SECRET_KEY']
    EasyPost.api_key = ENV['EASYPOST_API_KEY']
    @stripe_customer = Stripe::Customer.retrieve(current_user.retailer.stripe_id)
    if @commit.shipping.present?
      tracker = EasyPost::Tracker.retrieve(@commit.shipping.tracking_id)
      fees = 0
      tracker.fees.each do |fee|
        fees += fee.amount
      end
    end
  end

  def shipping_addresses
    @new_shipping_address = ShippingAddress.new
  end

  def last_chance
    @products = Product.where('id in (
      select product_id from commits where retailer_id = ?)
    AND id in
      (select product_id from product_tokens where expiration_datetime > ?)
    ', current_user.retailer.id, Time.current).page(params[:page]).per_page(6)
    # @products = current_user.retailer.commits.where('product_id in (select product_id from product_tokens where expiration_datetime > ?)', Time.current)
  end

  private
  def user_password_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def authenticate_retailer
    return redirect_to "/wholesaler" if current_user.is_wholesaler?
    @retailer = current_user.retailer
  end

end
