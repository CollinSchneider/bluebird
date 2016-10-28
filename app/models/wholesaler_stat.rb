class WholesalerStat < ActiveRecord::Base

  has_one :wholesaler

  def rating
    return ((self.total_rating.to_f/self.total_number_ratings.to_f).to_f.round(2))
  end

  def average_shipping
    avg_seconds = self.total_shipping_difference/total_shipments
    avg_minutes = (avg_seconds/60).to_f
    avg_hours = (avg_minutes/60).to_f
    avg_days = (avg_hours/24).to_f
    if avg_days < 1
      return "Less than a day"
    else
      return "About #{avg_days.round} days"
    end
  end

end
