class Wholesaler < ActiveRecord::Base

  belongs_to :user

  has_many :products

  def needs_stripe_connect?
    return self.stripe_id.nil?
  end

  def company
    self.user.company
  end

end
