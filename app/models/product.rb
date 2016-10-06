class Product < ActiveRecord::Base

  belongs_to :wholesaler

  has_many :commits
  has_many :product_features

  has_one :product_token

  validates :main_image, presence: true
  validates :title, presence: true
  validates :description, presence: true
  # validates :start_time, presence: true
  # validates :end_time, presence: true
  validates :price, presence: true
  validates :discount, presence: true
  validates :category, presence: true
  validates :retail_price, presence: true

  validate :enough_inventory_for_sale, :discount_price_is_lower, :retail_price_is_more

  has_attached_file :main_image, styles: {large: "600x600!", medium: "300x300!", thumb: "100x100!" }
  validates_attachment_content_type :main_image, content_type: /\Aimage\/.*\Z/

  has_attached_file :photo_two, styles: {large: "600x600!", medium: "300x300!", thumb: "100x100!" }
  validates_attachment_content_type :photo_two, content_type: /\Aimage\/.*\Z/

  has_attached_file :photo_three, styles: {large: "600x600!", medium: "300x300!", thumb: "100x100!" }
  validates_attachment_content_type :photo_three, content_type: /\Aimage\/.*\Z/

  has_attached_file :photo_four, styles: {large: "600x600!", medium: "300x300!", thumb: "100x100!" }
  validates_attachment_content_type :photo_four, content_type: /\Aimage\/.*\Z/

  has_attached_file :photo_five, styles: {large: "600x600!", medium: "300x300!", thumb: "100x100!" }
  validates_attachment_content_type :photo_five, content_type: /\Aimage\/.*\Z/

  before_validation(on: :create) do
    self.uuid = SecureRandom.uuid
    self.slug = make_slug
  end

  def create_uuid
    self.uuid = SecureRandom.uuid
  end

  def make_slug
    slug = self.title.downcase
    slug.gsub!(',' '')
    slug.gsub!("'", "")
    slug.gsub!('.', '')
    slug.gsub!(' ', '-')
    return self.slug = slug
  end

  def set_product_start_data
    self.status = 'live'
    self.current_sales = 0
    self.start_time = Time.now
    self.percent_discount = '%.2f' % (self.percent_discount*100)
    self.make_slug
    if self.duration == '1_day'
      self.end_time = Time.now.beginning_of_day + 1.day + 21.hours
    elsif self.duration == '7_days'
      self.end_time = Time.now.beginning_of_day + 7.days + 21.hours
    elsif self.duration == '10_days'
      self.end_time = Time.now.beginning_of_day + 10.days + 21.hours
    elsif self.duration == '14_days'
      self.end_time = Time.now.beginning_of_day + 14.days + 21.hours
    elsif self.duration == '30_days'
      self.end_time = Time.now.beginning_of_day + 30.days + 21.hours
    elsif self.duration = '5_minutes'
      self.end_time = (Time.now + 20.minutes)
    end
    self.save
  end

  def percentage
    total_orders = Commit.where('product_id = ?', self.id).sum(:amount).to_i
    total_sales = total_orders*self.discount.to_f
    percentage = ((total_sales/self.goal.to_f)*100)
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

  def percent_to_discount
    total_orders = Commit.where('product_id = ?', self.id).sum(:amount).to_i
    percentage = ((self.total_sales/self.goal.to_f)*100)
    return percentage
  end

  def price_with_fee
    return self.discount.to_f + (self.price.to_f-self.discount.to_f)*Commit::BLUEBIRD_PERCENT_FEE
  end

  def total_sales
    total_commits = self.commits.sum(:amount).to_f
    return total_commits*self.discount.to_f
  end

  def purchases_to_discount
    sales_left = self.goal.to_f - self.total_sales
    return (sales_left/self.discount.to_f).ceil
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
    seconds = self.end_time - Time.now
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
    seconds = self.product_token.expiration_datetime - Time.now
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

  def percent_discount
    return 1 - (self.price_with_fee.to_f/self.price.to_f)
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
                              OR LOWER(description) LIKE ? AND end_time > ? AND status = ?
                              OR wholesaler_id in (
                                select id from wholesalers where user_id in (
                                  select user_id from companies where company_key like ?
                                )
                              ) AND end_time > ? AND status = ?',
                              "%#{slug}%", Time.now, 'live',
                              "%#{slug}%", Time.now, 'live',
                              "%#{slug}%", Time.now, 'live')
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
                              "%#{slug}%", Time.now, category, 'live',
                              "%#{slug}%", Time.now, category, 'live',
                              "%#{slug}%", Time.now, category, 'live')
  end

  def self.end_full_priced
    products = Product.where('status = ? AND id in (
      select product_id from product_tokens where expiration_datetime <= ?
    )', 'full_price', Time.now + 30.seconds)
    products.each do |product|
      # Send email to wholesaler
      product.status = 'past'
      product.save
    end
  end

  def self.expire_products
    products = Product.where('status = ? AND end_time <= ?', 'live', Time.now + 30.seconds)
    goal_met_products = 0
    needs_attention_products = 0
    products.each do |product|
      # if product.commits.sum(:amount).to_f*product.discount.to_f >= product.goal.to_f
      if product.current_sales.to_f >= product.goal.to_f
        goal_met_products += 1
        product.status = 'goal_met'
        product.save(validate: false)
        product.commits.each do |commit|
          commit.status = 'goal_met'
          commit.sale_made = true
          commit.save(validate: false)
          charge = product.wholesaler.user.collect_payment(commit)
          if charge[1]
            # Mailer.retailer_discount_hit(commit.retailer.user, commit, product).deliver_later
          else
            # commit.card_declined = true
            # commit.card_decline_date = Time.now
            # commit.save(validate: false)
            # Send card failure email
          end
        end
        # Mailer.wholesaler_discount_hit(product.wholesaler.user, product).deliver_later
      else
        needs_attention_products += 1
        product.status = 'needs_attention'
        product.save(validate: false)
        product.commits.each do |commit|
          commit.status = 'pending'
          commit.save(validate: false)
          BlueBirdEmail.retailer_discount_missed(commit.user, product)
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
