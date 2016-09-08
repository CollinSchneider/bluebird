class ShippingAddress < ActiveRecord::Base

  belongs_to :retailer
  has_one :commit

end
