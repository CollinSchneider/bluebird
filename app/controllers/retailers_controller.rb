require 'easypost'
class RetailersController < ApplicationController
  before_action :authenticate_retailer
  layout 'retailer'

  def index
    redirect_to "/retailer/#{current_user.retailer.declined_order}/card_declined" if current_user.retailer.card_declined?
    @products = Product.where('id in (
      select product_id from commits where retailer_id = ? AND status = ? AND full_price != ?
    )', current_user.retailer.id, 'live', true)
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
      @past_orders = current_user.retailer.commits.where('stripe_charge_id IS NOT NULL AND product_id in (
        select id from products where status = ? OR status = ? or status = ?
      ) AND product_id in (
        select id from products where slug LIKE ? OR LOWER(description) LIKE ? OR wholesaler_id in (
          select id from wholesalers where user_id in (
            select user_id from companies where company_key LIKE ?
          )
        )
      )', 'full_price', 'discount_granted', 'goal_met', "%#{slug}%", "%#{slug}%", "%#{slug}%"
      ).order(created_at: :desc).page(params[:page]).per_page(9)
    else
      @past_orders = current_user.retailer.commits.where('stripe_charge_id IS NOT NULL AND product_id in (
        select id from products where status = ? OR status = ? or status = ?
      )', 'full_price', 'discount_granted', 'goal_met').order(created_at: :desc).page(params[:page]).per_page(9)
    end
  end

  def show_order_history
    @order = Commit.find(params[:id])
    EasyPost.api_key = ENV['EASYPOST_API_KEY']
    Stripe.api_key = ENV['STRIPE_SECRET_KEY']
    @easypost = EasyPost::Tracker.retrieve(@order.shipping_id)
    charge = Stripe::Charge.retrieve(@order.shipping_charge_id, :stripe_account => @order.product.wholesaler.stripe_id)
    @shipping_amount = '%.2f' % (charge.amount/100)
    redirect_to "/retailer/pending_orders" if @order.retailer.id != current_user.retailer.id
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
      if params[:user][:password] == params[:user][:password_confirmation]
        if params[:user][:password].length > 7
          current_user.update(user_password_params)
          current_user.skip_user_validation = true
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
    end
  end

  def card_declined
    @commit = Commit.find_by_uuid(params[:order_uuid]) || FullPriceCommit.find_by_uuid(params[:order_uuid])
    redirect_to '/retailer' if !@commit.card_declined
    Stripe.api_key = ENV['STRIPE_SECRET_KEY']
    EasyPost.api_key = ENV['EASYPOST_API_KEY']
    @stripe_customer = Stripe::Customer.retrieve(current_user.retailer.stripe_id)
    if !@commit.shipping_id.nil?
      tracker = EasyPost::Tracker.retrieve(@commit.shipping_id)
      fees = 0
      tracker.fees.each do |fee|
        fees += fee.amount
      end
    end
  end

  def last_chance
    @products = Product.where('id in (
      select product_id from commits where retailer_id = ?)
    AND id in
      (select product_id from product_tokens where expiration_datetime > ?)
    ', current_user.retailer.id, Time.now).page(params[:page]).per_page(3)
    # @products = current_user.retailer.commits.where('product_id in (select product_id from product_tokens where expiration_datetime > ?)', Time.now)
  end

  private
  def user_password_params
    params.require(:user).permit(:password, :password_confirmation)
  end

end
