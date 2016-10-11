class Shipping < ActiveRecord::Base

  has_many :commits
  belongs_to :retailer
  belongs_to :wholesaler

end
