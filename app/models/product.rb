class Product < ActiveRecord::Base

  belongs_to :user
  belongs_to :batch
  has_many :milestones
  has_many :commits

  has_attached_file :main_image, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: "/images/:style/missing.png"
  validates_attachment_content_type :main_image, content_type: /\Aimage\/.*\Z/

  has_attached_file :photo_two, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: "/images/:style/missing.png"
  validates_attachment_content_type :photo_two, content_type: /\Aimage\/.*\Z/

  has_attached_file :photo_three, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: "/images/:style/missing.png"
  validates_attachment_content_type :photo_three, content_type: /\Aimage\/.*\Z/

  has_attached_file :photo_four, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: "/images/:style/missing.png"
  validates_attachment_content_type :photo_four, content_type: /\Aimage\/.*\Z/

  has_attached_file :photo_five, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: "/images/:style/missing.png"
  validates_attachment_content_type :photo_five, content_type: /\Aimage\/.*\Z/

end
