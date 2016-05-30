require 'stripe'

class ApiController < ApplicationController

  def create_credit_card
    token = params[:token]
    customer = Stripe::Customer.retrieve(current_user.stripe_customer_id)
    customer.sources.create(:source => token)
  end

  def charge_credit_card
    customer = Stripe::Customer.retrieve(current_user.stripe_customer_id)
    Stripe.api_key = ENV["STRIPE_SECRET_KEY"]
    Stripe::Charge.create(
      :amount => 100000,
      :customer => customer.id,
      :currency => 'usd'
    )
  end

end
