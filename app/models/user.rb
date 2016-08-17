require 'stripe'

class User < ActiveRecord::Base
  has_secure_password

  validates :password, presence: true
  validates :email, presence: true, uniqueness: true
  validates :user_type, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :company_name, presence: true

  has_many :products
  has_many :milestones, through: :products
  has_many :commits
  has_many :shipping_addresses

  has_one :stripe_credential

  before_validation(on: :save) do
  end

  def create_uuid
    self.uuid = SecureRandom.uuid
    self.save
  end

  def make_stripe_customer
    Stripe.api_key = ENV["STRIPE_SECRET_KEY"]
    customer = Stripe::Customer.create(
      :description => "Customer for #{self.email}"
    )
    self.retailer_stripe_id = customer.id
    self.save
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

  def create_key
    slug = self.company_name
    slug = slug.gsub(' ', '-')
    slug = slug.gsub('.', '')
    slug = slug.gsub(',', '')
    slug = slug.gsub("'", "")
    self.key = slug.downcase
    self.save
  end

  def full_name
    "#{self.first_name.capitalize} #{self.last_name.capitalize}"
  end

  def is_wholesaler?
    return self.user_type == 'wholesaler'
  end

  def is_retailer?
    return self.user_type == 'retailer'
  end

  def needs_stripe_connect?
    return self.stripe_credential.nil?
  end

  def needs_credit_card?
    Stripe.api_key = ENV["STRIPE_SECRET_KEY"]
    customer = Stripe::Customer.retrieve(self.retailer_stripe_id)
    return customer.default_source.nil?
  end

  def needs_shipping_info?
    return !self.shipping_addresses.any?
  end

end
