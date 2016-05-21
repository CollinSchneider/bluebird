class Product < ActiveRecord::Base

  belongs_to :user
  belongs_to :batch
  has_many :milestones
  has_many :commits

end
