class ProductSizing < ActiveRecord::Base

  belongs_to :product
  has_many :skus

end
