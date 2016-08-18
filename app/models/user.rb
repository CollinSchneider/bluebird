require 'stripe'

class User < ActiveRecord::Base
  attr_accessor :updating
  has_secure_password

  validates :password, presence: true, length: 8..20, unless: :updating
  validates :email, presence: true, uniqueness: true, unless: :updating
  validates :first_name, presence: true, unless: :updating
  validates :last_name, presence: true, unless: :updating

  has_many :shipping_addresses

  has_one :wholesaler
  has_one :retailer
  has_one :company

  before_create(on: :save) do
    self.uuid = SecureRandom.uuid
  end

  def create_uuid
    self.uuid = SecureRandom.uuid
  end

  def collect_payment(commit, shipping_cost)
    Stripe.api_key = ENV["STRIPE_SECRET_KEY"]
    customer_stripe_id = commit.user.retailer_stripe_id
    customer_card = Stripe::Customer.retrieve(customer_stripe_id).default_source

    dollar_amount = (commit.amount.to_f*commit.product.discount.to_f) + shipping_cost
    stripe_amount = dollar_amount.to_f*100
    stripe_fee = (stripe_amount*0.029 + 30).floor
    bluebird_fee = (stripe_amount*0.05).floor
    wholesaler_amount = (stripe_amount - stripe_fee - bluebird_fee).floor
    charge_attrs = {
      amount: wholesaler_amount,
      currency: 'usd',
      customer: customer_stripe_id,
      source: customer_card,
      description: "#{commit.product.title} BlueBird.club purchase",
      application_fee: bluebird_fee + stripe_fee,
      destination: self.stripe_credential.stripe_user_id
    }
    charge = Stripe::Charge.create( charge_attrs )
    commit.stripe_charge_id = charge.id
    commit.sale_amount = wholesaler_amount
    commit.save!
    return charge
  end

  def full_name
    "#{self.first_name.capitalize} #{self.last_name.capitalize}"
  end

  def is_wholesaler?
    return self.wholesaler.present?
  end

  def is_retailer?
    return self.retailer.present?
  end

end
