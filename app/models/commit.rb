class Commit < ActiveRecord::Base

  belongs_to :retailer
  belongs_to :product
  belongs_to :shipping_address

  validate :meets_minimum_order
  validate :enough_inventory
  # validate :product_live

  # before_create(on: :save) do
  #   self.uuid = SecureRandom.uuid
  #   self.status = 'live'
  #   self.refunded = false
  # end

  def set_commit
    self.uuid = SecureRandom.uuid
    self.status = 'live'
    self.refunded = false
    self.set_primary_card_id_and_address
    self.set_sale_amount
    self.save
  end

  def set_primary_card_id_and_address
    Stripe.api_key = ENV['STRIPE_SECRET_KEY']
    customer = Stripe::Customer.retrieve(self.retailer.stripe_id)
    self.card_id = customer.default_source
    self.shipping_address_id = self.retailer.primary_address_id
  end

  def set_sale_amount
    if self.full_price
      self.sale_amount = self.product.price.to_f*self.amount
    else
      self.sale_amount = self.product.discount.to_f*self.amount
    end
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
