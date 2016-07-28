require 'stripe'
require "net/http"
require "uri"
require 'easypost'
require 'prawn'
class ApiController < ApplicationController

  def create_tracking
    commit = params[:commit_id]
    tracking_code = params[:tracking_number]
    EasyPost.api_key = "sl7EFdaoEC2GaVf5qYjz0g"
    binding.pry
    tracker = EasyPost::Tracker.create({
      tracking_code: tracking_code,
      carrier: "USPS"
    })
    render :json => {:shipment => tracker}
  end

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
  end

  def create_shipping_address
    street_one = params[:street_one]
    street_two = params[:street_two]
    city = params[:city]
    state = params[:state]
    zip = params[:zip]
    company = params[:company]
    phone = params[:phone]
    EasyPost.api_key = "sl7EFdaoEC2GaVf5qYjz0g"
    verifiable_address = EasyPost::Address.create(
      verify: ["delivery"],
      street1: street_one,
      street2: street_two,
      city: city,
      state: state,
      zip: zip,
      country: "US",
      company: company,
      phone: phone
    )
    # render :json => {address: verifiable_address}
    if verifiable_address.verifications.delivery.success
      local_address = ShippingAddress.new
      local_address.user_id = current_user.id
      local_address.address_id = verifiable_address.id
      local_address.save
    else
      flash[:error] = verifiable_address.verifications.delivery.errors.each
    end
    binding.pry
  end

  def save_shipping_id
    address_id = params[:address_id]
    shipping_address = ShippingAddress.create(:address_id => address_id, :user_id => current_user.id)
    render :json => {shipping_address: shipping_address}
  end

  def purchase_shipment
    shipment_id = params[:shipment_id]
    rate = params[:rate].to_i
    EasyPost.api_key = "sl7EFdaoEC2GaVf5qYjz0g"
    shipment = EasyPost::Shipment.retrieve(shipment_id)
    shipment_return = shipment.buy(rate: shipment.rates[rate])
    render :json => {:shipment => shipment_return}
  end

  def create_shipment
    binding.pry
    shipping_to = params[:to_address]
    length = params[:length]
    width = params[:width]
    height = params[:height]
    weight = params[:weight]
    EasyPost.api_key = "sl7EFdaoEC2GaVf5qYjz0g"
    to_address = EasyPost::Address.retrieve(shipping_to)
    from_address = EasyPost::Address.retrieve(current_user.shipping_addresses[0].address_id)
    shipment = EasyPost::Shipment.create(
      to_address: to_address,
      from_address: from_address,
      parcel: {
        length: height,
        width: width,
        height: height,
        weight: weight
      }
    )
    render :json => {:shipment => shipment}
  end

  def ship_batch
    EasyPost.api_key = "sl7EFdaoEC2GaVf5qYjz0g"
    shipment_details = EasyPost::Shipment.create(
      to_address: {
        name: 'Dr. Steve Brule',
        street1: '179 N Harbor Dr',
        city: 'Redondo Beach',
        state: 'CA',
        zip: '90277',
        country: 'US',
        phone: '4155559999',
        email: 'dr_steve_brule@gmail.com'
      },
      from_address: {
        name: 'EasyPost',
        street1: '118 2nd St',
        city: 'San Francisco',
        state: 'CA',
        zip: '94105',
        country: 'US',
        phone: '4155559999',
        email: 'support@easypost.com'
      },
      parcel: {
        length: 20.2,
        width: 10.9,
        height: 5,
        weight: 65.9
      },
    )
    binding.pry
    render :json => {shipping_details: shipment_details}
  end

  def save_shipment
    shipping_id = params[:shipping_id]
    commit = Commit.find(params[:commit_id])
    commit.shipping_id = shipping_id
    commit.save
    render :json => {commit: commit}
  end

  def get_shipping_label
    EasyPost.api_key = "sl7EFdaoEC2GaVf5qYjz0g"
    shipping_id = params[:shipping_id]
    shipment = EasyPost::Shipment.retrieve(shipping_id)
    # binding.pry
    # shipping = shipment.buy(rate: shipment.rates.first)
    render :json => {shipping: shipment}
  end

  def grant_discount
    product = Product.find(params[:product_id])
    product.status = 'discount_granted'
    product.save
    render :json => {:product => product}
  end

  def expire_product
    product = Product.find(params[:product_id])
    product.status = 'not_met'
    product.save
    render :json => {:product => product}
  end

end
