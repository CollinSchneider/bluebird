class Batch < ActiveRecord::Base

  belongs_to :user
  has_many :products
  has_many :milestones

  def time_frame(start_time, end_time)
    "#{start_time.strftime('%l:%M %P')} on #{start_time.strftime('%B %d, %Y')} to #{end_time.strftime('%l:%M %P')} on #{end_time.strftime('%B %d, %Y')}"
  end

  def time_difference(start_time, end_time)
      seconds_diff = (start_time - end_time).to_i.abs
      days = seconds_diff/(3600*24)
      seconds_diff -= days
      hours = seconds_diff/3600
      real_hours = (hours - days*24).floor
      seconds_diff -= hours*3600
      minutes = seconds_diff/60
      seconds_diff -= minutes*60
      seconds = seconds_diff
      "#{days.to_s.rjust(2, '0')}:#{real_hours.to_s.rjust(2, '0')}:#{minutes.to_s.rjust(2, '0')}:#{seconds.to_s.rjust(2, '0')}"
    end

end
