class Retailer < ActiveRecord::Base

  belongs_to :user

  has_many :commits
  has_many :shipping_addresses
  has_many :sales
  has_many :shippings

  before_create(on: :save) do
    self.stripe_id = make_stripe_customer
  end

  def make_stripe_customer
    Stripe.api_key = ENV["STRIPE_SECRET_KEY"]
    customer = Stripe::Customer.create(
      :description => "Customer for #{self.user.full_name}"
    )
    return customer.id
  end

  def primary_address
    self.shipping_addresses.where(:primary => true).first
  end

  def primary_address_id
    self.shipping_addresses.where(:primary => true).first.id
  end

  def company
    self.user.company
  end

  def needs_credit_card?
    Stripe.api_key = ENV["STRIPE_SECRET_KEY"]
    customer = Stripe::Customer.retrieve(self.stripe_id)
    return customer.default_source.nil?
  end

  def needs_shipping_info?
    return !self.shipping_addresses.any?
  end

  def card_declined?
    return self.sales.where(:card_failed => true).any? || self.shippings.where(:card_failed => true).any?
  end

  def declined_order
    sale_failed = self.sales.where(:card_failed => true).order(card_failed_date: :asc).first.commit_id
    return sale_failed if !sale_failed.nil?
    shipping_failed = self.shipping.where(:card_failed => true).order(card_failed_date: :asc).first.commit_id
    return shipping_failed if !shipping_failed.nil?
  end

  def successful_orders
    self.commits.where('status = ? OR status = ?', 'goal_met', 'discount_granted')
  end

  def total_savings
    total_savings = 0
    self.sales.each do |sale|
      total_savings += (sale.commit.product.price.to_f*sale.commit.amount.to_f) - (sale.sale_amount + sale.charge_amount)
    end
    return total_savings
  end

end
