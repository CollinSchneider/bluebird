class Wholesaler < ActiveRecord::Base

  belongs_to :user

  has_many :products

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
    self.contactable_by_phone || self.contactable_by_email ? true : false
  end

  def total_revenue
    orders = Commit.where('status = ? AND product_id in (
      select id from products where wholesaler_id = ?
    ) OR status = ? AND product_id in (
      select id from products where wholesaler_id = ?
    )', 'live', self.id, 'full_price', self.id)
    total_sales = 0
    orders.each do |order|
      if order.full_price
        total_sales += order.amount.to_f*order.product.price.to_f
      else
        total_sales += order.amount.to_f*order.product.discount.to_f
      end
    end
    return total_sales
  end

end
