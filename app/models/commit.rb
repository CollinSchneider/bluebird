class Commit < ActiveRecord::Base

  belongs_to :retailer
  belongs_to :product

  before_validation(on: :create) do
    self.uuid = SecureRandom.uuid
    self.status = 'live'
  end

  def set_primary_card_id
    Stripe.api_key = ENV['STRIPE_SECRET_KEY']
    customer = Stripe::Customer.retrieve(self.retailer.stripe_id)
    self.card_id = customer.default_source
  end

end
