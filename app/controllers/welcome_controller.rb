require 'stripe'
class WelcomeController < ApplicationController

  def shop
    @products = Product.where('status = ?', 'live')
    Stripe.api_key = ENV["STRIPE_SECRET_KEY"]
    @stripe_customer = Stripe::Customer.retrieve(current_user.stripe_customer_id)
  end

end
