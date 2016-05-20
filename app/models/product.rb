class Product < ActiveRecord::Base

  belongs_to :user
  has_many :milestones
  has_many :commits

end
