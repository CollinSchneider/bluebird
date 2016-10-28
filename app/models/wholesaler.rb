class Wholesaler < ActiveRecord::Base

  belongs_to :user
  belongs_to :return_policy
  belongs_to :wholesaler_stat

  has_many :products
  has_many :commits
  has_many :purchase_orders, through: :commits
  has_many :sales
  has_many :ratings, through: :sales
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

  def orders_to_ship
    return self.purchase_orders.where("(purchase_orders.sale_made = 't' or purchase_orders.full_price = 't') and purchase_orders.has_shipped = 'f' and purchase_orders.refunded = 'f' and commit_id not in (
      select commit_id from sales where card_failed = 't'
    )")
  end

  def rating
    return (self.total_rating.to_f/self.total_number_ratings.to_f).to_f
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
    (!self.user.company.contact_email.nil? && self.user.company.contact_email != '') || (!self.user.company.contact_number.nil? && self.user.company.contact_number != '')
  end

  def contactable_by_phone
    !self.user.company.contact_number.nil? && self.user.company.contact_number != ''
  end

  def contactable_by_email
    !self.user.company.contact_email.nil? && self.user.company.contact_number != ''
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
