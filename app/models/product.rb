class Product < ActiveRecord::Base

  after_create :make_slug_and_uuid

  belongs_to :wholesaler

  has_many :commits
  has_many :purchase_orders, through: :commits
  has_many :product_features
  has_many :product_sizings
  has_many :product_variants
  has_many :skus

  has_one :product_token

  validates :main_image, presence: true
  validates :title, presence: true
  validates :category, presence: true

  has_attached_file :main_image, styles: {large: "600x600!", medium: "300x300!", thumb: "100x100!" }, :s3_protocol => 'https'
  validates_attachment_content_type :main_image, content_type: /\Aimage\/.*\Z/

  has_attached_file :photo_two, styles: {large: "600x600!", medium: "300x300!", thumb: "100x100!" }, :s3_protocol => 'https'
  validates_attachment_content_type :photo_two, content_type: /\Aimage\/.*\Z/

  has_attached_file :photo_three, styles: {large: "600x600!", medium: "300x300!", thumb: "100x100!" }, :s3_protocol => 'https'
  validates_attachment_content_type :photo_three, content_type: /\Aimage\/.*\Z/

  has_attached_file :photo_four, styles: {large: "600x600!", medium: "300x300!", thumb: "100x100!" }, :s3_protocol => 'https'
  validates_attachment_content_type :photo_four, content_type: /\Aimage\/.*\Z/

  has_attached_file :photo_five, styles: {large: "600x600!", medium: "300x300!", thumb: "100x100!" }, :s3_protocol => 'https'
  validates_attachment_content_type :photo_five, content_type: /\Aimage\/.*\Z/

  def make_slug_and_uuid
    self.slug = Util.slug(self.title)
    self.uuid = SecureRandom.uuid
    self.save
  end

  def set_product_start_data
    self.status = 'live'
    self.current_sales = 0
    self.current_sales_with_fees = 0
    self.start_time = Time.current
    self.slug = Util.slug(self.title)
    self.minimum_order || = 1
    if self.duration == '1_day'
      self.end_time = Time.current.end_of_day + 1.day
    elsif self.duration == '7_days'
      self.end_time = Time.current.end_of_day + 7.days
    elsif self.duration == '10_days'
      self.end_time = Time.current.end_of_day + 10.days
    elsif self.duration == '14_days'
      self.end_time = Time.current.end_of_day + 14.days
    elsif self.duration == '30_days'
      self.end_time = Time.current.end_of_day + 30.days
    elsif self.duration = '5_minutes'
      self.end_time = (Time.current + 5.minutes)
    end
    self.save
  end

  def percentage
    percentage = ((self.current_sales/self.goal.to_f)*100)
    if percentage >= 100
      progress = 100
      progress_class = 'meter striped animate col s8 offset-s2 no-padding'
    else
      progress = percentage
      progress_class = 'meter col s8 offset-s2 no-padding'
    end
    return {
      'progress_bar' => "width: #{progress.floor}%",
      'percent_to_discount' => percentage.floor,
      'class' => progress_class
    }
  end

  def percent_discount_with_fee
    return (self.skus.first.price - self.skus.first.price_with_fee)/self.skus.first.price
  end

  def orders_to_discount
    if self.current_sales < self.goal
      if self.skus_same_wholesale_price?
        return "#{((self.goal - self.current_sales)/self.skus.first.discount_price).ceil} orders away from discount"
      else
        discount = 0
        self.skus.each do |sku|
          discount += sku.discount_price
        end
        return "About #{((self.goal - self.current_sales)/(discount/self.skus.count)).ceil} orders away from discount"
      end
    else
      return "Discount reached!"
    end
  end

  def percent_to_discount
    total_orders = Commit.where('product_id = ?', self.id).sum(:amount).to_i
    percentage = ((self.total_sales/self.goal.to_f)*100)
    return percentage
  end

  def average_full_price
    if self.skus_same_wholesale_price?
      return "$#{'%.2f' % self.skus.first.price}"
    else
      skus = 0
      price = 0
      self.skus.each do |sku|
        skus += 1
        price += sku.price
      end
      return "$#{'%.2f' % (price/skus)}"
    end
  end

  def average_discount_price
    if self.skus_same_wholesale_price?
      return "$#{'%.2f' % self.skus.first.price_with_fee}"
    else
      skus = 0
      discount = 0
      self.skus.each do |sku|
        skus += 1
        discount += sku.price_with_fee
      end
      return "$#{'%.2f' % (discount/skus)}"
    end
  end

  def average_price_with_fee
    if self.skus_same_wholesale_price?
      return "$#{'%.2f' % self.skus.first.price_with_fee}"
    else
      fee = 0
      self.skus.each do |sku|
        fee += sku.price_with_fee
      end
      return "$#{'%.2f' % (fee/self.skus.count)}"
    end
  end

  def suggested_retail_range
    if self.skus_same_retail_price?
      return "$#{'%.2f' % self.skus.first.suggested_retail}"
    else
      skus = self.skus.order(suggested_retail: :asc)
      return "$#{'%.2f' % skus.first.suggested_retail} - #{'%.2f' % skus.last.suggested_retail}"
    end
  end

  def price_with_fee_range
    if self.skus_same_wholesale_price?
      "$#{'%.2f' % self.skus.first.price_with_fee}"
    else
      skus = self.skus.order(price_with_fee: :asc)
      return "$#{'%.2f' % skus.first.price_with_fee} - $#{'%.2f' % skus.last.price_with_fee}"
    end
  end

  def discount_price_range
    if self.skus_same_wholesale_price?
      return "$#{'%.2f' % self.skus.first.discount_price}"
    else
      skus = self.skus.order(discount_price: :asc)
      return "$#{'%.2f' % skus.first.discount_price} - $#{'%.2f' % skus.last.discount_price}"
    end
  end

  def full_price_range
    if self.skus_same_wholesale_price?
      return "$#{'%.2f' % self.skus.first.price}"
    else
      skus = self.skus.order(price: :asc)
      return "$#{'%.2f' % skus.first.price} - $#{'%.2f' % skus.last.price}"
    end
  end

  def price_with_fee
    return self.discount.to_f + (self.price.to_f-self.discount.to_f)*Commit::BLUEBIRD_PERCENT_FEE
  end

  def total_sales
    total_commits = self.commits.sum(:amount).to_f
    return total_commits*self.discount.to_f
  end

  def purchases_to_discount
    # sales_left = self.goal.to_f - self.total_sales
    # return (sales_left/self.discount.to_f).ceil
  end

  def has_variants?
    return self.product_variants.count > 0
  end

  def has_sizes?
    return self.product_sizings.count > 0
  end

  def skus_same_retail_price?
    return self.skus.pluck(:suggested_retail).uniq.count == 1
  end

  def skus_same_wholesale_price?
    return self.skus.pluck(:price).uniq.count == 1
  end

  def result
    result = case self.status
      when "goal_met" then "Goal Met"
      when "discount_granted" then "Discount Granted"
      when "past" then "Discount Missed"
      else nil
    end
    return result
  end

  def is_users?(user)
    if user.is_wholesaler?
      return self.wholesaler_id == user.wholesaler.id
    end
  end

  def calc_end_time
    return self.end_time.strftime('%l:%M %P on %b %d, %Y')
  end

  def time_to_expiration
    seconds = self.end_time - Time.current
    minutes = seconds/60
    hours = minutes/60
    days = hours/24
    if days > 2
      return "#{days.floor} days left"
    elsif days < 2 && days > 0
      hours = days*24
      if hours > 1
        return "#{(hours).floor}\n hours left"
      else
        return "#{(hours*60).floor}\n minutes left"
      end
    else
      return "Expired #{self.end_time.strftime('%b %d')}"
    end
  end

  def time_to_full_price_expiration
    seconds = self.product_token.expiration_datetime - Time.current
    minutes = seconds/60
    hours = minutes/60
    days = hours/24
    if days > 2
      return "#{days.floor} days left"
    elsif days < 2 && days > 0
      hours = days*24
      if hours > 1
        return "#{(hours).floor}\n hours left"
      else
        return "#{(hours*60).floor}\n minutes left"
      end
    else
      return "Expired #{self.end_time.strftime('%b %d')}"
    end
  end

  def full_price?
    return self.status == 'full_price'
  end

  def self.queried_products(query)
    slug = query.downcase
    slug.gsub!(',' '')
    slug.gsub!("'", "")
    slug.gsub!('.', '')
    slug.gsub!(' ', '-')
    slug.gsub!('?', '')
    slug.gsub!('!', '')
    @products = Product.where('slug LIKE ? AND end_time > ? AND status = ?
                              OR LOWER(short_description) LIKE ? AND end_time > ? AND status = ?
                              OR LOWER(long_description) LIKE ? AND end_time > ? AND status = ?
                              OR wholesaler_id in (
                                select id from wholesalers where user_id in (
                                  select user_id from companies where company_key like ?
                                )
                              ) AND end_time > ? AND status = ?',
                              "%#{slug}%", Time.current, 'live',
                              "%#{slug}%", Time.current, 'live',
                              "%#{slug}%", Time.current, 'live',
                              "%#{slug}%", Time.current, 'live')
  end

  def self.category_queried_products(query, category)
    slug = query.downcase
    slug.gsub!(',' '')
    slug.gsub!("'", "")
    slug.gsub!('.', '')
    slug.gsub!(' ', '-')
    @products = Product.where('slug LIKE ? AND end_time > ? AND category = ? AND status = ?
                              OR LOWER(description) LIKE ? AND end_time > ? AND category = ? AND status = ?
                              OR wholesaler_id in (
                                select id from wholesalers where user_id in (
                                  select user_id from companies where company_key like ?
                                )
                              ) AND end_time > ? AND category = ? AND status = ?',
                              "%#{slug}%", Time.current, category, 'live',
                              "%#{slug}%", Time.current, category, 'live',
                              "%#{slug}%", Time.current, category, 'live')
  end

  def self.end_full_priced
    products = Product.where('status = ? AND id in (
      select product_id from product_tokens where expiration_datetime <= ?
    )', 'full_price', Time.current + 30.seconds)
    products.each do |product|
      # Send email to wholesaler
      product.status = 'past'
      product.save
    end
  end

  def self.expire_products
    products = Product.where('status = ? AND end_time <= ?', 'live', Time.current + 30.seconds)
    goal_met_products = 0
    needs_attention_products = 0
    products.each do |product|
      # if product.commits.sum(:amount).to_f*product.discount.to_f >= product.goal.to_f
      if product.current_sales.to_f >= product.goal.to_f
        goal_met_products += 1
        product.status = 'goal_met'
        product.save(validate: false)
        BlueBirdEmail.wholesaler_discount_hit(product.wholesaler.user, product)
        product.commits.each do |commit|
          commit.status = 'goal_met'
          commit.sale_made = true
          commit.save(validate: false)
          commit.purchase_orders.each do |po|
            po.sale_made = true
            po.save!
          end
          BlueBirdEmail.retailer_discount_hit(commit.retailer.user, commit, commit.product)
          product.wholesaler.user.collect_payment(commit)
        end
      else
        needs_attention_products += 1
        product.status = 'needs_attention'
        product.save(validate: false)
        product.commits.each do |commit|
          commit.status = 'pending'
          commit.save(validate: false)
        end
        BlueBirdEmail.wholesaler_needs_attention(product.wholesaler.user, product)
      end
    end
    return goal_met_products, needs_attention_products
  end

  # VALIDATIONS
  def enough_inventory_for_sale
    if self.goal.to_f > self.discount.to_f*self.quantity.to_f
      errors.add(:error, ": Your sales goal is not attainable with your current discount price and inventory selling.")
    end
  end

  def retail_price_is_more
    if self.retail_price.to_f < self.price.to_f
      errors.add(:error, ": Your retail price must be higher than your full wholesale price.")
    end
  end

  def discount_price_is_lower
    if self.discount.to_f >= self.price.to_f
      errors.add(:error, ": Your discounted wholesale price must be lower than your full wholesale price.")
    end
  end

end
