require 'easypost'
class RetailersController < ApplicationController
  before_action :authenticate_retailer
  layout 'retailer'

  def signup
  end

  def index
    @products = Product.where('id in (
      select product_id from commits where user_id = ? AND status = ?
    )', current_user.id, 'live')
    @pending_orders = current_user.commits.where('status = ?', 'live')
    @unfulfilled_orders = current_user.commits.where('product_id in (
      select id from products where status = ?
    )', 'not_met')
    @fulfilled_orders = current_user.commits.where('product_id in (
      select id from products where status = ? or status = ?
    )', 'goal_met', 'granted_discount')
    # current_user.commits.each do |commit|
    #   if commit.status == 'goal_met' || commit.status == 'granted_discount'
    #     @fulfilled_orders.push(commit)
    #   elsif commit.status == 'not_met'
    #     @unfulfilled_orders.push(commit)
    #   elsif commit.status == 'live'
    #     @pending_orders.push(commit)
    #   end
    # end
    EasyPost.api_key = ENV['EASYPOST_API_KEY']
    @users_addresses = []
    current_user.shipping_addresses.each do |address|
      easy_post_address = EasyPost::Address.retrieve(address.address_id)
      @users_addresses.push(easy_post_address)
    end
  end

  def order_history
    @past_orders = current_user.commits.order(created_at: :asc)
  end

  def accounts
    Stripe.api_key = ENV['STRIPE_SECRET_KEY']
    @stripe_customer = Stripe::Customer.retrieve(current_user.retailer_stripe_id)
    if @stripe_customer.default_source
      @default_card = @stripe_customer.sources.retrieve(@stripe_customer.default_source)
    end
  end

  def settings
  end

  def change_password
    if request.put?
      current_user.update(user_password_params)
      current_user.save(validate: false)
      if current_user.save(validate: false)
        flash[:success] = "Password Updated"
      else
        flash[:error] = current_user.errors
      end
      redirect_to request.referrer
    end
  end

  private
  def user_password_params
    params.require(:user).permit(:password)
  end

end
