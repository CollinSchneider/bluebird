class Wholesaler < ActiveRecord::Base

  belongs_to :user

  has_many :products
  has_many :commits
  has_many :sales
  has_many :shippings

  # before_create(on: :save) do
  #   self.approved = false
  #   self.contactable_by_phone = false
  #   self.contactable_by_email = false
  # end

  def needs_attention?
    return !self.products.where('status = ?', 'needs_attention').empty?
  end

  def needs_to_ship?
    return self.commits.where("sale_made = 't' AND has_shipped = 'f' AND id NOT IN (
      select commit_id from sales where card_failed = 't'
    )").any?
  end

  def products_to_ship
    return self.commits.where("sale_made = 't' AND has_shipped = 'f' AND id NOT IN (
      select commit_id from sales where card_failed = 't'
    )")
  end

  def declined_commits
    declined_commits = self.sales.where(:card_failed => true).count
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
