class Sku < ActiveRecord::Base

  ################################
  #  code = Product-Variant-Size #
  ################################

  belongs_to :product_sizing
  belongs_to :product_variant
  belongs_to :product
  has_many :purchase_orders

  validate :retail_price_is_more

  before_create :generate_number

  def generate_number
    loop do
      self.number = Util.random_string('sku')
      break if Sku.find_by(:number => number).nil?
    end
  end

  def display_inventory
    inventory < 50 ? "only #{inventory} left in stock" : nil
  end

  def is_first?
    return self.product.skus.count == self.product.skus.where('price IS NULL AND suggested_retail IS NULL AND inventory IS NULL').count
  end

  def self.is_done?(product)
    return !product.skus.where('price is null OR suggested_retail is null OR inventory is null').any?
  end

  def image
    return self.product_variant_id.nil? ? self.product.main_image : self.product_variant.image
  end

  def description
    if !self.product_variant_id.nil? && !self.product_sizing_id.nil?
      return "#{self.product_sizing.description} #{self.product_variant.description}"
    elsif !self.product_sizing_id.nil?
      return "#{self.product_sizing.description} #{self.product.title}"
    elsif !self.product_variant_id.nil?
      return "#{self.product_variant.description} #{self.product.title}"
    else
      return "#{self.product.title}"
    end
  end

  def savings
    if !product.full_price?
      price - price_with_fee
    else
      0
    end
  end

  def user_ordered?(user)
    return !user.retailer.purchase_orders.find_by(:sku_id => self.id).nil?
  end

  def out_of_inventory?
    return self.inventory == 0
  end

  def remove_sku
    self.product_variant.skus.count
  end

  # VALIDATORS

  def retail_price_is_more
    if self.suggested_retail.to_f <= self.price.to_f
      errors.add(:Your, " retail price must be higher than your full wholesale price.")
    end
  end

end
