require 'stripe'

class User < ActiveRecord::Base
  has_secure_password(validate: false)
  attr_accessor :editing_password, :editing_user_info

  validates :password, presence: true, confirmation: true, length: 8..20, on: :editing_password
  validates :email, presence: true, uniqueness: true
  validates :first_name, presence: true
  validates :last_name, presence: true

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
    customer = Stripe::Customer.retrieve(customer_stripe_id)
    customer_card = customer.sources.retrieve(commit.card_id)
    shipping_cost = 1000

    token = Stripe::Token.create(
      {:customer => customer_stripe_id, :card => customer_card.id},
      {:stripe_account => self.wholesaler.stripe_id} # id of the connected account
    )
    payment = Payment.new

    begin
      charge = Stripe::Charge.create({
          :amount => shipping_cost.floor, # amount in cents
          :currency => "usd",
          :source => token,
          :description => "#{commit.product.title} BlueBird.club purchase"
          # :destination => self.wholesaler.stripe_id
        },
        {:stripe_account => self.wholesaler.stripe_id}
      )
      if !charge.nil?
        payment.retailer_id = commit.retailer.id
        commit.wholesaler_id = commit.product.wholesaler.id
        payment.commit_id = commit.id
        payment.payment_type = 'shipping'
        payment.amount = shipping_cost.floor/100
        payment.stripe_charge_id = charge.id
        payment.refunded = false
        payment.card_failed = false
        payment.save!
        success = true
        return success, charge
      end
    rescue Stripe::CardError => e
      success = false
      payment.card_declined = true
      payment.card_decline_date = Time.now
      payment.declined_reason = e.message
      Mailer.card_declined(commit.retailer.user, commit, customer_card)
      payment.save!
      return success, e.message
    end
  end

  def collect_payment(commit, amount)
    Stripe.api_key = ENV["STRIPE_SECRET_KEY"]
    customer_stripe_id = commit.retailer.stripe_id
    customer = Stripe::Customer.retrieve(customer_stripe_id)
    customer_card = customer.sources.retrieve(commit.card_id)

    token = Stripe::Token.create(
      {:customer => customer_stripe_id, :card => customer_card.id},
      {:stripe_account => self.wholesaler.stripe_id} # id of the connected account
    )
    payment = Payment.new

    stripe_amount = amount.to_f*100
    bluebird_fee = (stripe_amount*0.05).floor
    begin
      charge = Stripe::Charge.create({
          :amount => stripe_amount.floor, # amount in cents
          :currency => "usd",
          :source => token,
          :description => "#{commit.product.title} BlueBird.club purchase",
          :application_fee => bluebird_fee # amount in cents
        },
        {:stripe_account => self.wholesaler.stripe_id}
      )
      if !charge.nil?
        payment.retailer_id = commit.retailer.id
        commit.wholesaler_id = commit.product.wholesaler.id
        payment.commit_id = commit.id
        payment.payment_type = 'sale'
        payment.amount = shipping_cost.floor/100
        payment.stripe_charge_id = charge.id
        payment.refunded = false
        payment.card_failed = false
        payment.save!
        success = true
        return charge, success
      end
    rescue Stripe::CardError => e
      success = false
      payment.card_declined = true
      payment.card_decline_date = Time.now
      payment.declined_reason = e.message
      Mailer.card_declined(commit.retailer.user, commit, customer_card)
      payment.save!
      return e.message, success
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
