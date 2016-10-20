class PurchaseOrder < ActiveRecord::Base

  after_create :set_purchase_order

  belongs_to :wholesaler
  belongs_to :retailer
  belongs_to :product
  belongs_to :sku
  belongs_to :commit
  belongs_to :shipping

  before_create(on: :save) do
  end

  def set_purchase_order
    self.refunded = false
    self.sale_made = false
    self.has_shipped = false
    self.save
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
