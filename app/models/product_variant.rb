class ProductVariant < ActiveRecord::Base

  belongs_to :product
  has_many :skus

  has_attached_file :image, styles: {large: "600x600!", medium: "300x300!", thumb: "100x100!" }, :s3_protocol => 'https'
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/

end
