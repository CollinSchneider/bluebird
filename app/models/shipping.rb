class Shipping < ActiveRecord::Base

  has_many :commits
  has_many :purchase_orders
  belongs_to :retailer
  belongs_to :wholesaler

end
