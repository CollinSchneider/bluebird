class Milestone < ActiveRecord::Base

  belongs_to :product
  belongs_to :batch

end
