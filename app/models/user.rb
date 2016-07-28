require 'stripe'

class User < ActiveRecord::Base
  has_secure_password

  # validates :password, presence: true
  # validates :email, presence: true, uniqueness: true

  has_many :products
  has_many :milestones, through: :products
  has_many :commits
  has_many :shipping_addresses

  def make_stripe_customer
    Stripe.api_key = ENV['STRIPE_SECRET_KEY']
    customer = Stripe::Customer.create(
      :description => "Customer for #{self.email}"
    )
    self.retailer_stripe_id = customer.id
    self.save
  end

  def is_wholesaler?
    # return false unless self.user_type == 'wholesaler'
    return !self.wholesaler_stripe_id.nil?
  end

  def is_retailer?
    # return false unless self.user_type == 'retailer'
    return !self.retailer_stripe_id.nil?
  end

  # TODO: This works for checking if wholesaler, need to make Stripe API call
  def needs_stripe_connect?
    return !self.wholesaler_stripe_id
  end

  # TODO: needs Stripe API call
  def needs_credit_card?
    return !self.retailer_stripe_id
  end

  def needs_shipping_address?
    return self.shipping_addresses.length.nil?
  end

end
