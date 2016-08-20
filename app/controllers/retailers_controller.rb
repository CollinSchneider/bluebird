require 'easypost'
class RetailersController < ApplicationController
  before_action :authenticate_retailer
  layout 'retailer'

  def index
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
    @past_orders = current_user.retailer.commits.order(created_at: :asc)
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
    # @declined_commits = current_user.retailer.commits.where('card_declined = ?', true)
    Stripe.api_key = ENV['STRIPE_SECRET_KEY']
    EasyPost.api_key = ENV['EASYPOST_API_KEY']
    @stripe_customer = Stripe::Customer.retrieve(current_user.retailer.stripe_id)
  end

  private
  def user_password_params
    params.require(:user).permit(:password)
  end

end
