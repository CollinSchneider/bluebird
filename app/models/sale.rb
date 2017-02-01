class Sale < ActiveRecord::Base

  belongs_to :commit
  belongs_to :retailer
  belongs_to :wholesaler
  has_one :rating

  before_create :generate_number

  def generate_number
    loop do
      self.number = Util.random_string('sale')
      break if Sale.find_by(:number => number).nil?
    end
  end

end
