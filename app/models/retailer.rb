class Retailer < ActiveRecord::Base

  belongs_to :user

  has_many :commits
  has_many :shipping_addresses

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
    declined_commits = self.commits.where(:card_declined => true)
    return !declined_commits.empty?
  end

  def declined_order
    declined_id = self.commits.where(:card_declined => true).order(card_decline_date: :asc).pluck(:uuid)
    return declined_id.first
  end

  def successful_orders
    self.commits.where(:status => 'goal_met')
  end

  def total_savings
    total_price = 0
    total_spent = 0
    self.successful_ordersi.each do |order|
      total_spent += order.amount.to_f*order.product.discount.to_f
      total_price += order.amount.to_f*order.product.price.to_f
    end
    return total_price - total_spent
  end

end
