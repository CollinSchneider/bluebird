class Commit < ActiveRecord::Base

  BLUEBIRD_PERCENT_FEE = 0.2

  belongs_to :retailer
  belongs_to :wholesaler
  belongs_to :product
  belongs_to :shipping_address
  belongs_to :shipping

  has_one :sale

  has_many :purchase_orders

  # validate :meets_minimum_order
  # validate :enough_inventory
  # validate :product_live

  # before_create(on: :save) do
  #   self.uuid = SecureRandom.uuid
  #   self.status = 'live'
  #   self.refunded = false
  # end

  def set_commit(user)
    self.uuid = SecureRandom.uuid
    self.refunded = false
    self.retailer_id = user.retailer.id
    self.wholesaler_id = self.product.wholesaler_id
    self.set_primary_card_id_and_address
    return self.save
  end

  def set_primary_card_id_and_address
    Stripe.api_key = ENV['STRIPE_SECRET_KEY']
    customer = Stripe::Customer.retrieve(self.retailer.stripe_id)
    self.card_id = customer.default_source
    self.shipping_address_id = self.retailer.primary_address_id
  end

  def destroy_commit
    self.product.quantity += self.amount
    new_sales = (self.product.current_sales.to_f) - (self.amount.to_i*self.product.discount.to_f)
    self.product.current_sales = new_sales
    self.product.save
    self.destroy
  end

  def amount_saved
    return (self.sale_amount_with_fees*(1+(self.product.percent_discount/100))) - self.sale_amount_with_fees
  end

  # def total_price
  #   total = 0
  #   if self.full_price?
  #     return self.sale_amount
  #   else
  #     self.purchase_orders.each do |po|
  #       total += po.quantity*po.sku.price_with_fee
  #     end
  #     return total
  #   end
  # end

  def price_with_shipping
    shipping_amount = self.shipping_amount.nil? ? 0 : self.shipping_amount
    return self.sale_amount_with_fees + shipping_amount
  end

  def bluebird_fee
    self.full_price? ? 0 : self.amount_saved*Commit::BLUEBIRD_PERCENT_FEE
  end

  def current_status
    return 'Refunded' if self.refunded
    return 'Sale Still Live' if self.status == 'live'
    return 'Sale Reached' if self.sale_made
    return 'Pending' if self.status == 'pending'
    return 'Last Chance' if self.status == 'past' && self.product.product_token.expiration_datetime > Time.now
    return 'Sale Not Reached' if self.status = 'past'
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
      if !self.amount_was.nil?
        if self.product.quantity.to_i - (self.amount - self.amount_was) < 0
          return errors.add(:Whoops!, "Looks like there's only #{self.product.quantity} left in inventory, update your order accordingly.")
        end
      else
        return errors.add(:Whoops!, "Looks like there's only #{self.product.quantity} left in inventory, update your order accordingly.")
      end
    end
  end

  def product_live
    if self.product.end_time < Time.now
      errors.add(:Just_missed, " it! This sale ended at #{self.product.calc_end_time}.")
    end
  end

end
