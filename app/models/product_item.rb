class ProductItem < ActiveRecord::Base

  belongs_to :product
  has_many :commits

end
