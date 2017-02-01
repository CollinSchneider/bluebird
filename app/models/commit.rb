class Commit < ActiveRecord::Base

  BLUEBIRD_PERCENT_FEE = 0.2

  belongs_to :retailer
  belongs_to :wholesaler
  belongs_to :product
  belongs_to :shipping_address
  belongs_to :shipping

  has_one :sale

  has_many :purchase_orders
  has_many :skus, through: :purchase_orders
  accepts_nested_attributes_for :purchase_orders

  before_create :generate_number
  after_save :create_rating

  # after_commit :update_product_amount

  # validate :meets_minimum_order
  def update_product_amounts
    commits = Commit.where(:product_id => self.product_id)
    price_with_fee = commits.collect(&:sale_amount_with_fees).reduce(:+)
    price = commits.collect(&:sale_amount).reduce(:+)
    if price_with_fee.nil?
      product.current_sales_with_fees = 0
      product.current_sales = 0
    else
      product.current_sales_with_fees = price_with_fee
      product.current_sales = price
    end
    product.save(validate: false)
  end

  def meets_minimum_order
    if amount < product.minimum_order
      errors.add(:base, "Total Orders must meet the minimum amount of #{product.minimum_order} items.")
    end
  end

  def create_rating
    if sale.present? && !sale.rating.present?
      Rating.create(:sale_id => self.sale.id)
    end
  end

  def generate_number
    loop do
      self.number = Util.random_string('order')
      break if Commit.find_by(:number => number).nil?
    end
  end

  def add_po(sku, quantity)
    PurchaseOrder.create(
      :sku_id => sku.id,
      :commit => self,
      :quantity => quantity,
      :sale_amount => quantity*sku.discount_price,
      :sale_amount_with_fees => quantity*sku.price_with_fee
    )
    # sku.inventory -= quantity
    # sku.save!
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
    total_price = purchase_orders.collect { |po| po.quantity*po.sku.price }
    total_paid = purchase_orders.collect { |po| po.quantity*po.sku.price_with_fee }
    return total_price.inject(:+) - total_paid.inject(:+)
  end

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
    return 'Last Chance' if self.status == 'past' && self.product.product_token.expiration_datetime > Time.current
    return 'Sale Not Reached' if self.status = 'past'
  end

  def set_sale_amounts
    # if status_changed? && status == 'live'
    og_commit_sale_amount_with_fees = sale_amount_with_fees
    og_commit_sale_amount = sale_amount
      if !full_price
        prices = purchase_orders.each.collect { |po| po.quantity*po.sku.discount_price }
        self.sale_amount = prices.inject(:+)
        with_fees = purchase_orders.each.collect { |po| po.quantity*po.sku.price_with_fee }
        self.sale_amount_with_fees = with_fees.inject(:+)
      else
        prices = purchase_orders.each.collect { |po| po.quantity*po.sku.price }
        self.sale_amount = prices.inject(:+)
        self.sale_amount_with_fees = sale_amount
      end
      order_amounts = purchase_orders.collect { |po| po.quantity }
      self.amount = order_amounts.inject(:+)
      self.save!
      product.current_sales += (sale_amount - og_commit_sale_amount)
      product.current_sales_with_fees += (sale_amount_with_fees - og_commit_sale_amount_with_fees)
      product.save!
    # end
  end

  # VALIDATIONS
  # def meets_minimum_order
  #   if !self.product.minimum_order.nil?
  #     if self.amount.to_i < self.product.minimum_order
  #       errors.add(:Your_order, "amount does not meet this products minimum order amount of #{self.product.minimum_order}.")
  #     end
  #   end
  # end

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
    if self.product.end_time < Time.current
      errors.add(:Just_missed, " it! This sale ended at #{self.product.calc_end_time}.")
    end
  end

end
