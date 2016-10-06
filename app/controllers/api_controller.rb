require 'stripe'
require "net/http"
require "uri"
require 'easypost'
require 'prawn'
class ApiController < ApplicationController

  def save_shipping_id
    address_id = params[:address_id]
    shipping_address = ShippingAddress.create(:address_id => address_id, :user_id => current_user.id)
    render :json => {shipping_address: shipping_address}
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
      BlueBirdEmail.retailer_discount_hit(commit.retailer.user, commit, product)
      commit.status = 'discount_granted'
      current_user.collect_payment(commit)
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
      BlueBirdEmail.retailer_discount_missed(commit.retailer.user, product)
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
      user.password_reset_expiration = Time.now + 1.hour
      user.save(validate: false)
      BlueBirdEmail.forgot_password(user)
      render :json => {message: "Instructions has been sent to #{email}, you have 30 minutes to reset your password."}
    else
      render :json => {message: "No users found with the email of #{email}."}
    end
  end

end
