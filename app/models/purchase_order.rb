class PurchaseOrder < ActiveRecord::Base

  after_create :set_purchase_order

  belongs_to :wholesaler
  belongs_to :retailer
  belongs_to :product
  belongs_to :sku
  belongs_to :commit
  belongs_to :shipping

  after_commit :update_commit_amounts
  after_commit :update_skus
  after_destroy :check_to_delete_commit

  # Able to do this because only time purchase orders are touched is to change quantity/delete
  def update_commit_amounts
    pos = PurchaseOrder.where(:commit_id => self.commit_id)
    total_orders = pos.collect(&:quantity).reduce(:+) || 0
    sale_amount = pos.collect(&:sale_amount).reduce(:+) || 0
    sale_amount_with_fees = pos.collect(&:sale_amount_with_fees).reduce(:+) || 0
    if total_orders > 0
      commit.amount = total_orders
      commit.sale_amount = sale_amount
      commit.sale_amount_with_fees = sale_amount_with_fees
      commit.save(validate: false)
    end
    commit.update_product_amounts
  end

  def update_skus
    total_quantity = sku.purchase_orders.collect(&:quantity).reduce(:+) || 0
    if total_quantity > 0
      sku.inventory -= total_quantity
      sku.save(validate: false)
    # else
    #   commit.destroy
    end
  end

  def check_to_delete_commit
    if commit.purchase_orders.empty?
      sku.inventory += quantity
      sku.save(validate: false)
      commit.destroy
      commit.update_product_amounts
    end
  end

  def set_purchase_order
    self.refunded = false
    self.sale_made = false
    self.has_shipped = false
    self.save
  end

  def total_saved
    if !full_price?
      sku.price*quantity - total_paid
    else
      0
    end
  end

  def total_paid
    price_paid_each*quantity
  end

  def wholesaler_earned
    collected_each = full_price? ? sku.price : sku.discount_price
    collected_each*quantity
  end

  def bluebird_earned
    total_paid - wholesaler_earned
  end

  def price_paid_each
    if full_price?
      sku.price
    else
      sku.price_with_fee
    end
  end

  def full_price?
    self.full_price == true
  end

  def delete_order
    order_amount = self.quantity
    commit = self.commit
    self.sku.inventory += order_amount
    commit.sale_amount -= order_amount*self.sku.discount_price
    commit.sale_amount_with_fees -= order_amount*self.sku.price_with_fee
    commit.amount -= order_amount
    commit.product.current_sales -= order_amount*self.sku.discount_price
    commit.product.current_sales_with_fees -= order_amount*self.sku.price_with_fee
    commit.save!
    commit.product.save!
    self.sku.save!
    if commit.purchase_orders.length < 2
      self.delete
      return commit.delete
    end
    self.delete
  end

end
