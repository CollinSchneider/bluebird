require 'easypost'
class RetailersController < ApplicationController

  def signup
  end

  def index
    authneticate_retailer
    @pending_orders = []
    @unfulfilled_orders = []
    @fulfilled_orders = []
    current_user.commits.each do |commit|
      if commit.status == 'goal_met' || commit.status == 'granted_discount'
        @fulfilled_orders.push(commit)
      elsif commit.status == 'not_met'
        @unfulfilled_orders.push(commit)
      elsif commit.status == 'live'
        @pending_orders.push(commit)
      end
    end
    # EasyPost.api_key = "sl7EFdaoEC2GaVf5qYjz0g"
    # @users_addresses = []
    # current_user.shipping_addresses.each do |address|
    #   easy_post_address = EasyPost::Address.retrieve(address.address_id)
    #   @users_addresses.push(easy_post_address)
    # end
  end

  def order_history
    @past_orders = current_user.commits.order(created_at: :asc)
  end

  def accounts
    Stripe.api_key = ENV["STRIPE_SECRET_KEY"]
    @stripe_customer = Stripe::Customer.retrieve(current_user.retailer_stripe_id)
    if @stripe_customer.default_source
      @default_card = @stripe_customer.sources.retrieve(@stripe_customer.default_source)
    end
  end

end
