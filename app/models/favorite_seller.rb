class FavoriteSeller < ActiveRecord::Base

  validates_uniqueness_of :wholesaler_id, scope: :retailer_id

  belongs_to :retailer
  belongs_to :wholesaler

end
