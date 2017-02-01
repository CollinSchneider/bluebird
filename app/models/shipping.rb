class Shipping < ActiveRecord::Base

  has_many :commits
  has_many :purchase_orders
  belongs_to :retailer
  belongs_to :wholesaler

  before_create :generate_number

  def generate_number
    loop do
      self.number = Util.random_string('shipment')
      break if Shipping.find_by(:number => number).nil?
    end
  end

end
