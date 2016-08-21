require 'stripe'
require "net/http"
require "uri"
require 'easypost'
require 'prawn'
class ApiController < ApplicationController

  def stripe_connect_charge
    commit_id = params[:commit_id]
    commit = Commit.find(commit_id)

    stripe_charge = current_user.collect_payment(commit)
    render :json => stripe_charge
  end

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

    charge = current_user.collect_payment(commit)
    # render :json => {
    #   :charge => charge,
    #   :shipment => tracker
    # }
    # Mailer.retailer_sale_shipped(commit.retailer.user, tracker.carrier, tracker.tracking_code, tracker.est_delivery_date, tracker.public_url).deliver_later
  end

  def delete_credit_card
    card_id = params[:card_id]
    customer = Stripe::Customer.retrieve(current_user.retailer.stripe_id)
    card = customer.sources.retrieve(card_id).delete
    redirect_to request.referrer
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
      current_user.collect_payment(commit)
      commit.save(validate: false)
    end
  end

  def expire_product
    product = Product.find(params[:product_id])
    product.status = 'full_price'
    product.current_sales = 0
    product.save(validate: false)
    pt = ProductToken.new
    pt.product_id = product.id
    pt.token = SecureRandom.uuid
    pt.expiration_datetime = Time.now + 7.days
    pt.save
    render :json => {:product => product}
    product.commits.each do |commit|
      Mailer.retailer_discount_missed(commit.user, product).deliver_later
      commit.status = 'past'
      commit.save(validate: false)
    end
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
