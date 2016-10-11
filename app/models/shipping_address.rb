class ShippingAddress < ActiveRecord::Base

  belongs_to :retailer
  has_many :commits

  def orders_to_ship
    self.commits.where("sale_made = 't' AND has_shipped = 'f' AND refunded = 'f' AND id not in (
      select commit_id from sales where card_failed = 't'
    )")
  end

end
