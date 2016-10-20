class ShippingAddress < ActiveRecord::Base

  belongs_to :retailer
  has_many :commits
  has_many :purchase_orders, through: :commits

  def orders_to_ship
    return self.purchase_orders.where("purchase_orders.sale_made = 't' and purchase_orders.has_shipped = 'f' and purchase_orders.refunded = 'f' and commit_id not in (
      select commit_id from sales where card_failed = 't'
    ) OR purchase_orders.full_price = 't' and purchase_orders.has_shipped = 'f' and purchase_orders.refunded = 'f' AND commit_id in (
      select id from commits where full_price = 't'
    )")
  end

end
