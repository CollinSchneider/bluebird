class Batch < ActiveRecord::Base

  belongs_to :user
  has_many :products
  has_many :milestones

  # def self.time_frame
  #   "#{self.start_time.strftime('%l:%M %P')} on #{self.start_time.strftime('%B %d, %Y')} to #{self.end_time.strftime('%l:%M %P')} on #{self.end_time.strftime('%B %d, %Y')}"
  # end

end
