require 'stripe'
require "net/http"
require "uri"
require 'easypost'
require 'prawn'
class ApiController < ApplicationController

  def create_tracking_and_charge
    tracking_code = params[:tracking_number]
    amount = params[:amount]
    # EasyPost.api_key = ENV["EASYPOST_API_KEY"]
    # tracker = EasyPost::Tracker.create({
    #   tracking_code: tracking_code
    # })
    commit = Commit.find(params[:commit_id])
    # commit.shipping_id = tracker.id
    # commit.save!
    shipping_cost = 30
    # tracker.fees.each do |fee|
    #   shipping_cost += fee.amount.to_f
    # end
    amount = commit.amount.to_i*commit.product.discount.to_f
    charge = current_user.collect_payment(commit, amount)
    # render :json => {
    #   :charge => charge,
    #   :shipment => tracker
    # }
    # Mailer.retailer_sale_shipped(commit.retailer.user, tracker.carrier, tracker.tracking_code, tracker.est_delivery_date, tracker.public_url).deliver_later
  end

  # def charge_credit_card
  #   customer = Stripe::Customer.retrieve(current_user.stripe_customer_id)
  #   Stripe.api_key = ENV["STRIPE_SECRET_KEY"]
  #   Stripe::Charge.create(
  #     :amount => 100000,
  #     :customer => customer.id,
  #     :currency => 'usd'
  #   )
  # end

  def save_shipping_id
    address_id = params[:address_id]
    shipping_address = ShippingAddress.create(:address_id => address_id, :user_id => current_user.id)
    render :json => {shipping_address: shipping_address}
  end

  def purchase_shipment
    shipment_id = params[:shipment_id]
    rate = params[:rate].to_i
    EasyPost.api_key = ENV["EASYPOST_API_KEY"]
    shipment = EasyPost::Shipment.retrieve(shipment_id)
    shipment_return = shipment.buy(rate: shipment.rates[rate])
    render :json => {:shipment => shipment_return}
  end

  def save_shipment
    shipping_id = params[:shipping_id]
    commit = Commit.find(params[:commit_id])
    commit.shipping_id = shipping_id
    commit.save
    render :json => {commit: commit}
  end

  def grant_discount
    product = Product.find(params[:product_id])
    product.status = 'discount_granted'
    product.save
    render :json => {:product => product}
    product.commits.each do |commit|
      # Mailer.retailer_discount_hit(commit.retailer.user, commit, product).deliver_later
      commit.status = 'discount_granted'
      amount = product.discount.to_f*commit.amount.to_f
      current_user.collect_payment(commit, amount)
      commit.save(validate: false)
    end
  end

  def expire_product
    product = Product.find(params[:product_id])
    pt = ProductToken.new
    pt.product_id = product.id
    pt.token = SecureRandom.uuid
    pt.expiration_datetime = (Time.now + 7.days + 1.hour).beginning_of_hour
    pt.save

    original_inventory = product.quantity.to_i
    product.commits.each do |commit|
      original_inventory += commit.amount.to_i
      Mailer.retailer_discount_missed(commit.retailer.user, product).deliver_later
      commit.status = 'past'
      commit.save(validate: false)
    end
    product.status = 'full_price'
    product.current_sales = 0
    product.quantity = original_inventory
    product.save(validate: false)
    render :json => {:product => product}
  end

  def send_password_reset
    email = params[:email]
    user = User.find_by_email(email)
    if user
      token = SecureRandom.uuid
      user.password_reset_token = token
      user.password_reset_expiration = Time.now + 30.minutes
      user.save(validate: false)
      Mailer.forgot_password(user).deliver_later
      render :json => {message: "Instructions has been sent to #{email}, you have 30 minutes to reset your password."}
    else
      render :json => {message: "No users found with the email of #{email}."}
    end
  end

end
