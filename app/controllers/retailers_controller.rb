require 'easypost'
class RetailersController < ApplicationController
  before_action :authenticate_retailer
  layout 'retailer'

  def index
    redirect_to "/retailer/#{current_user.retailer.declined_order}/card_declined" if current_user.retailer.card_declined?
    @products = Product.where('id in (
      select product_id from commits where retailer_id = ? AND status = ?
    )', current_user.retailer.id, 'live')
    @pending_orders = current_user.retailer.commits.where('status = ?', 'live')
    @unfulfilled_orders = current_user.retailer.commits.where('product_id in (
      select id from products where status = ?
    )', 'not_met')
    @fulfilled_orders = current_user.retailer.commits.where('product_id in (
      select id from products where status = ? or status = ?
    )', 'goal_met', 'granted_discount')
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
      @past_orders = current_user.retailer.commits.where('product_id in (
        select id from products where slug LIKE ? OR LOWER(description) LIKE ? OR wholesaler_id in (
          select id from wholesalers where user_id in (
            select user_id from companies where company_key LIKE ?
          )
        )
      )', "%#{slug}%", "%#{slug}%", "%#{slug}%").order(created_at: :asc).page(params[:page]).per_page(3)
    else
      @past_orders = current_user.retailer.commits.order(created_at: :asc).page(params[:page]).per_page(3)
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
      current_user.update(user_password_params)
      if current_user.save(validate: false)
        flash[:success] = "Password Updated"
      else
        flash[:error] = current_user.errors
      end
      redirect_to request.referrer
    end
  end

  def card_declined
    @commit = Commit.find(params[:order])
    redirect_to '/retailer' if !@commit.card_declined
    Stripe.api_key = ENV['STRIPE_SECRET_KEY']
    EasyPost.api_key = ENV['EASYPOST_API_KEY']
    @stripe_customer = Stripe::Customer.retrieve(current_user.retailer.stripe_id)
    if !@commit.shipping_id.nil?
      tracker = EasyPost::Tracker.retrieve(@commit.shipping_id)
      fees = 0
      binding.pry
      tracker.fees.each do |fee|
        fees += fee.amount
      end
    end
  end

  private
  def user_password_params
    params.require(:user).permit(:password)
  end

end
