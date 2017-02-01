class ShippingAddress < ActiveRecord::Base

  belongs_to :retailer
  has_many :commits
  has_many :purchase_orders, through: :commits

  validates :street_address_one, presence: true
  validates :city, presence: true
  validates :state, presence: true
  validates :zip, presence: true

  after_create :make_false

  def make_false
    if primary.nil?
      self.primary = false
      self.save
    end
  end

  def set_primary
    retailer.shipping_addresses.each do |add|
      add.primary = false
      add.save!
    end
    self.primary = true
    self.save!
  end

  def live_orders
    commits.where('status = ? or status = ?', 'live', 'pending')
  end

  def orders_to_ship
    return self.purchase_orders.where("purchase_orders.sale_made = 't' and purchase_orders.has_shipped = 'f' and purchase_orders.refunded = 'f' and commit_id not in (
      select commit_id from sales where card_failed = 't'
    ) OR purchase_orders.full_price = 't' and purchase_orders.has_shipped = 'f' and purchase_orders.refunded = 'f' AND commit_id in (
      select id from commits where full_price = 't'
    )")
  end

end
