class Sku < ActiveRecord::Base

  ################################
  #  code = Product-Variant-Size #
  ################################

  belongs_to :product_sizing
  belongs_to :product_variant
  belongs_to :product
  has_many :purchase_orders

  validate :retail_price_is_more

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
      return "#{self.product_sizing.description}"
    elsif !self.product_variant_id.nil?
      return "#{self.product_variant.description}"
    else
      return "#{self.product.title}"
    end
  end

  def user_ordered?(user)
    return !user.retailer.purchase_orders.find_by(:sku_id => self.id).nil?
  end

  def out_of_inventory?
    return self.inventory == 0
  end

  # VALIDATORS

  def retail_price_is_more
    if self.suggested_retail.to_f < self.price.to_f
      errors.add(:Your, " retail price must be higher than your full wholesale price.")
    end
  end

end
