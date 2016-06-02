require 'stripe'
require "net/http"
require "uri"
class ApiController < ApplicationController

  def create_credit_card
    token = params[:token]
    customer = Stripe::Customer.retrieve(current_user.retailer_stripe_id)
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

  def create_stripe_connect
    auth_code = params[:code]
    uri = URI.parse("https://connect.stripe.com/oauth/token")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(uri.request_uri)
    request.set_form_data({
      "client_secret" => ENV["STRIPE_SECRET_KEY"],
      "code" => auth_code,
      "grant_type" => "authorization_code"
    })
    response = http.request(request)
    data = JSON.parse(response.body)
    current_user.update(:wholesaler_stripe_id => data["stripe_user_id"])
    # current_user.wholesaler_stripe_id = data['stripe_user_id']
    current_user.save!
    render :json => {:data => data}
    redirect_to wholesaler_path
  end

  def send_money
    connected_stripe_account = params[:wholesaler_stripe_id]
    stripe_customer = params[:stripe_customer]
    Stripe.api_key = ENV["STRIPE_SECRET_KEY"]
    charge = Stripe::Charge.create({
      :amount => 1000,
      :currency => "usd",
      :customer => stripe_customer,
      :destination => connected_stripe_account,
      :application_fee => 200
    })
    render :json => {:charge => charge}
    # binding.pry
  end

end
