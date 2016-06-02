require 'stripe'
class WelcomeController < ApplicationController

  def shop
    @products = Product.where('status = ?', 'live')
    Stripe.api_key = ENV["STRIPE_SECRET_KEY"]
    if current_user.retailer_stripe_id
      @stripe_customer = Stripe::Customer.retrieve(current_user.retailer_stripe_id)
    end
  end

end
