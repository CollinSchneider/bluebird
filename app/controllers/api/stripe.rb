require 'stripe'
require "net/http"
require "uri"
require 'easypost'
class Api::StripeController < ApiController

  def create_tracking_and_charge
    tracking_code = params[:tracking_number]
    amount = params[:amount]
    EasyPost.api_key = "sl7EFdaoEC2GaVf5qYjz0g"
    tracker = EasyPost::Tracker.create({
      tracking_code: tracking_code,
      carrier: "USPS"
    })
    commit = Commit.find(params[:commit_id])
    commit.shipping_id = tracker.id
    commit.save!

    amount = commit.amount.to_f*commit.product.discount.to_f
    customer_stripe_id = commit.user.retailer_stripe_id
    vendor_stripe_id = current_user.wholesaler_stripe_id

    # binding.pry
    # Stripe.api_key = "sk_test_TI9EamOjFwLiHOvvNF6Q1cIn"
    # stripe_customer = Stripe::Customer.retrieve(customer_stripe_id)
    # customer_card = Stripe::Account.retrieve(stripe_customer.default_source)
    current_user.collect_payment(commit.user.retailer_stripe_id, amount)
    # stripe_amount = dollar_amount.to_f*100
    # charge_amount = stripe_amount*0.05
    # binding.pry
    # charge = Stripe::Charge.create({
    #   :amount => 1000,
    #   :currency => "usd",
    #   :customer => customer_card,
    #   :application_fee => 50
    # },
    #   {:destination => vendor_stripe_id}
    # )
    # binding.pry
    # render :json => {:shipment => tracker}
  end

end
