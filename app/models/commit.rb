class Commit < ActiveRecord::Base

  belongs_to :retailer
  belongs_to :product

  before_validation(on: :create) do
    # self.set_product_start_data
  end

  def create_uuid
    self.uuid = SecureRandom.uuid
    self.save
  end

end
