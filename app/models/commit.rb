class Commit < ActiveRecord::Base

  belongs_to :retailer
  belongs_to :product

  validate :meets_minimum_order
  validate :enough_inventory
  validate :product_live

  before_validation(on: :create) do
    self.uuid = SecureRandom.uuid
    self.status = 'live'
    self.refunded = false
  end

  def set_primary_card_id
    Stripe.api_key = ENV['STRIPE_SECRET_KEY']
    customer = Stripe::Customer.retrieve(self.retailer.stripe_id)
    self.card_id = customer.default_source
  end

  def full_price?
    return false
  end

  # VALIDATIONS
  def meets_minimum_order
    if !self.product.minimum_order.nil?
      if self.amount.to_i < self.product.minimum_order
        errors.add(:Your_order, "amount does not meet this products minimum order amount of #{self.product.minimum_order}.")
      end
    end
  end

  def enough_inventory
    if self.amount.to_i > self.product.quantity.to_i
      errors.add(:Whoops!, "Looks like there's only #{self.product.quantity} left in inventory, update your order accordingly.")
    end
  end

  def product_live
    if self.product.end_time < Time.now
      errors.add(:Just_missed, " it! This sale ended at #{self.product.calc_end_time}.")
    end
  end

end
