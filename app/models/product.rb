class Product < ActiveRecord::Base

  belongs_to :wholesaler
  has_many :commits

  has_one :product_token

  validates :main_image, presence: true
  validates :title, presence: true
  validates :description, presence: true
  # validates :start_time, presence: true
  # validates :end_time, presence: true
  validates :price, presence: true
  validates :discount, presence: true
  validates :category, presence: true

  validate :enough_inventory_for_sale

  has_attached_file :main_image, styles: {large: "600x600!", medium: "300x300!", thumb: "100x100!" }, default_url: "/images/:style/missing.png"
  validates_attachment_content_type :main_image, content_type: /\Aimage\/.*\Z/

  has_attached_file :photo_two, styles: {large: "600x600!", medium: "300x300!", thumb: "100x100!" }, default_url: "/images/:style/missing.png"
  validates_attachment_content_type :photo_two, content_type: /\Aimage\/.*\Z/

  has_attached_file :photo_three, styles: {large: "600x600!", medium: "300x300!", thumb: "100x100!" }, default_url: "/images/:style/missing.png"
  validates_attachment_content_type :photo_three, content_type: /\Aimage\/.*\Z/

  has_attached_file :photo_four, styles: {large: "600x600!", medium: "300x300!", thumb: "100x100!" }, default_url: "/images/:style/missing.png"
  validates_attachment_content_type :photo_four, content_type: /\Aimage\/.*\Z/

  has_attached_file :photo_five, styles: {large: "600x600!", medium: "300x300!", thumb: "100x100!" }, default_url: "/images/:style/missing.png"
  validates_attachment_content_type :photo_five, content_type: /\Aimage\/.*\Z/

  before_validation(on: :create) do

  end

  def create_uuid
    self.uuid = SecureRandom.uuid
    self.save
  end

  def make_slug
    slug = self.title.downcase
    slug.gsub!(',' '')
    slug.gsub!("'", "")
    slug.gsub!('.', '')
    slug.gsub!(' ', '-')
    self.slug = slug
  end

  def set_product_start_data
    self.status = 'live'
    self.current_sales = 0
    self.start_time = Time.now
    self.percent_discount = '%.2f' % (self.percent_discount*100)
    self.make_slug
    if self.duration == '1_day'
      self.end_time = (Time.now + 1.hour).beginning_of_hour + 1.day
    elsif self.duration == '7_days'
      self.end_time = (Time.now + 1.hour).beginning_of_hour + 7.days
    elsif self.duration == '10_days'
      self.end_time = (Time.now + 1.hour).beginning_of_hour + 10.days
    elsif self.duration == '14_days'
      self.end_time = (Time.now + 1.hour).beginning_of_hour + 14.days
    elsif self.duration == '30_days'
      self.end_time = (Time.now + 1.hour).beginning_of_hour + 30.days
    elsif self.duration = '5_minutes'
      self.end_time = (Time.now + 2.minutes)
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
      'progress_bar' => progress,
      'percent_to_discount' => percentage.floor,
      'class' => progress_class
    }
  end

  def percent_to_discount
    total_orders = Commit.where('product_id = ?', self.id).sum(:amount).to_i
    total_sales = total_orders*self.discount.to_f
    percentage = ((total_sales/self.goal.to_f)*100)
    return percentage
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

  def percent_discount
    return 1 - (self.discount.to_f/self.price.to_f)
  end

  def self.expire_product
    products = Product.where('status = ? AND end_time <= ?', 'live', Time.now)
    products.each do |product|
      if product.current_sales.to_f >= product.goal.to_f
        product.status = 'goal_met'
        product.save
        product.commits.each do |commit|
          commit.status = 'goal_met'
          commit.save(validate: false)
          Mailer.retailer_discount_hit(commit.user, commit, product).deliver_later
        end
        Mailer.wholesaler_discount_hit(product.user, product).deliver_later
      else
        product.status = 'needs_attention'
        product.save
        product.commits.each do |commit|
          commit.status = 'past'
          commit.save(validate: false)
          # Mailer.retailer_discount_missed(commit.user, product)
        end
        Mailer.wholesaler_needs_attention(product.user, product).deliver_later
      end
    end
  end

  # VALIDATIONS
  def enough_inventory_for_sale
    if self.goal.to_f > self.discount.to_f*self.quantity.to_f
      errors.add(:inventory_amount, "Your sales goal is not attainable with your current discount price and inventory selling")
    end
  end

end
