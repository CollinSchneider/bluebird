class Shipping < ActiveRecord::Base

  belongs_to :commit
  belongs_to :retailer
  belongs_to :wholesaler

end
