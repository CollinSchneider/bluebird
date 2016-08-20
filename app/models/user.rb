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
  has_one :admin
  has_one :company

  before_create(on: :save) do
    self.uuid = SecureRandom.uuid
  end

  def collect_shipping_charge(commit, shipping_cost)
    Stripe.api_key = ENV["STRIPE_SECRET_KEY"]
    customer_stripe_id = commit.retailer.stripe_id
    customer_card = Stripe::Customer.retrieve(customer_stripe_id).default_source

    charge_attrs = {
      amount: 1000,
      currency: 'usd',
      customer: customer_stripe_id,
      source: customer_card,
      description: "#{commit.product.title} shipping cost",
      destination: self.wholesaler.stripe_id
    }
    begin
      charge = Stripe::Charge.create( charge_attrs )
      success = true
      return success, charge
    rescue Stripe::CardError => e
      success = false
      commit.card_declined = true
      commit.card_decline_date = Time.now
      commit.declined_reason = e.message
      commit.save!
      return success, e.message
    end
  end

  def collect_payment(commit)
    Stripe.api_key = ENV["STRIPE_SECRET_KEY"]
    customer_stripe_id = commit.retailer.stripe_id
    customer = Stripe::Customer.retrieve(customer_stripe_id)
    customer_card = customer.sources.retrieve(commit.card_id)

    dollar_amount = (commit.amount.to_f*commit.product.discount.to_f)
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
      destination: self.wholesaler.stripe_id
    }
    begin
      charge = Stripe::Charge.create( charge_attrs )
      if !charge.nil?
        success = true
        commit.stripe_charge_id = charge.id
        commit.sale_amount = wholesaler_amount
        commit.card_declined = false
        commit.save!
        return charge, success
      end
    rescue Stripe::CardError => e
      success = false
      commit.card_declined = true
      commit.card_decline_date = Time.now
      commit.declined_reason = e.message
      commit.save!
      return e, success
    end
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

  def is_admin?
    return self.admin.present?
  end

end
