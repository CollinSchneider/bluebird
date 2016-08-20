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
    EasyPost.api_key = ENV['EASYPOST_API_KEY']
    if self.shipping_addresses.first
      address = EasyPost::Address.retrieve(self.shipping_addresses.first.address_id)
    else
      nil
    end
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
    declined_commits = self.commits.where('card_declined = ?', true)
    return !declined_commits.empty?
  end

  def declined_order
    declined_id = self.commits.where('card_declined = ?', true).pluck(:id)
    return declined_id.first
  end

end
