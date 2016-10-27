class Sale < ActiveRecord::Base

  belongs_to :commit
  belongs_to :retailer
  belongs_to :wholesaler
  has_one :rating

end
