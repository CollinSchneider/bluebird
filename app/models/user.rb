require 'stripe'

class User < ActiveRecord::Base
  has_secure_password(validate: false)
  attr_accessor :editing_password, :editing_user_info
  after_create :strip_fields

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

  def strip_fields
    self.first_name = self.first_name.strip
    self.last_name = self.last_name.strip
    self.email = self.email.strip
    self.phone_number = self.phone_number.strip
    self.save!
  end

  def collect_shipping_charge(commit, shipping_cost)
    shipping_cost = shipping_cost.to_f
    shipping = commit.shipping.nil? ? Shipping.new : commit.shipping
    shipping.commit_id = commit.id
    shipping.retailer_id = commit.retailer_id
    shipping.wholesaler_id = commit.wholesaler_id

    Stripe.api_key = ENV["STRIPE_SECRET_KEY"]
    customer_stripe_id = commit.retailer.stripe_id
    customer = Stripe::Customer.retrieve(customer_stripe_id)
    customer_card = customer.sources.retrieve(commit.card_id)
    shipping_cost += (shipping_cost*0.029+0.29)

    shipping.shipping_amount = shipping_cost

    token = Stripe::Token.create(
      {:customer => customer_stripe_id, :card => customer_card.id},
      {:stripe_account => self.wholesaler.stripe_id} # id of the connected account
    )

    begin
      charge = Stripe::Charge.create({
          :amount => (shipping_cost*100).ceil, # amount in cents
          :currency => "usd",
          :source => token,
          :description => "#{commit.retailer.user.full_name}'s BlueBird.club shipment"
        },
        {:stripe_account => self.wholesaler.stripe_id}
      )
      if !charge.nil?
        shipping.stripe_charge_id = charge.id
        shipping.card_failed = false
        shipping.card_failed_reason = nil
        shipping.card_failed_date = nil
        shipping.save(validate: false)
        success = true
        return success, charge
      end
    rescue Stripe::CardError => e
      success = false
      shipping.card_failed = true
      shipping.card_failed_reason = e.message
      shipping.card_failed_date = Time.now
      shipping.save(validate: false)
      return success, e.message
    end
  end

  def collect_payment(commit)
    commit_charge = commit.sale.nil? ? Sale.new : commit.sale
    commit_charge.commit_id = commit.id
    commit_charge.retailer_id = commit.retailer_id
    commit_charge.wholesaler_id = commit.product.wholesaler_id

    Stripe.api_key = ENV["STRIPE_SECRET_KEY"]
    customer_stripe_id = commit.retailer.stripe_id
    customer = Stripe::Customer.retrieve(customer_stripe_id)
    customer_card = customer.sources.retrieve(commit.card_id)

    if commit.full_price
      bluebird_fee = 0
      amount = commit.amount.to_f*commit.product.price.to_f
    else
      amount = commit.amount.to_f*commit.product.discount.to_f
      money_saved = commit.amount_saved*100
      bluebird_fee = (money_saved*Commit::BLUEBIRD_PERCENT_FEE).floor
    end
    commit_charge.sale_amount = amount
    commit_charge.charge_amount = bluebird_fee/100
    stripe_amount = amount.to_f*100 + bluebird_fee

    token = Stripe::Token.create(
      {:customer => customer_stripe_id, :card => customer_card.id},
      {:stripe_account => self.wholesaler.stripe_id}
    )

    begin
      charge = Stripe::Charge.create({
          :amount => stripe_amount.floor, # amount in cents
          :currency => "usd",
          :source => token,
          :description => "#{commit.retailer.user.full_name} BlueBird.club purchase of #{commit.product.title}",
          :application_fee => bluebird_fee # amount in cents
        },
        {:stripe_account => self.wholesaler.stripe_id}
      )
      if !charge.nil?
        commit_charge.stripe_charge_id = charge.id
        commit_charge.card_failed = false
        commit_charge.card_failed_reason = nil
        commit_charge.card_failed_date = nil
        commit_charge.save(validate: false)
        success = true
        return charge, success
      end
    rescue Stripe::CardError => e
      success = false
      commit_charge.card_failed = true
      commit_charge.card_failed_reason = e.message
      commit_charge.card_failed_date = Time.now
      commit_charge.save(validate: false)
      # Mailer.card_declined(commit.retailer.user, commit, customer_card).deliver_later
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
