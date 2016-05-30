require 'stripe'

class User < ActiveRecord::Base
  has_secure_password

  validates :password, presence: true
  validates :email, presence: true, uniqueness: true

  has_many :products
  has_many :commits
  has_many :batches

  def make_stripe_customer
    Stripe.api_key = ENV['STRIPE_SECRET_KEY']
    customer = Stripe::Customer.create(
      :description => "Customer for #{self.email}"
    )
    self.stripe_customer_id = customer.id
    self.save
  end

end
