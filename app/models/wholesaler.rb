class Wholesaler < ActiveRecord::Base

  belongs_to :user

  has_many :products
  has_many :payments

  # before_create(on: :save) do
  #   self.approved = false
  #   self.contactable_by_phone = false
  #   self.contactable_by_email = false
  # end

  def needs_attention?
    return !self.products.where('status = ?', 'needs_attention').empty?
  end

  def needs_to_ship?
    return !self.products.where('
                    products.status = ? OR products.status = ? OR products.status = ?',
                    'goal_met', 'discount_granted', 'full_price').joins(:commits).where('
                      shipping_id IS NULL AND card_declined != ?
                    ', true).empty?
  end

  def needs_stripe_connect?
    return self.stripe_id.nil?
  end

  def company
    self.user.company
  end

  def is_contactable?
    if self.contactable_by_phone || self.contactable_by_email
      return true
    else
      return false
    end
  end

end
