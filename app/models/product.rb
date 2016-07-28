class Product < ActiveRecord::Base

  belongs_to :user
  belongs_to :batch
  has_many :milestones
  has_many :commits

  has_attached_file :main_image, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: "/images/:style/missing.png"
  validates_attachment_content_type :main_image, content_type: /\Aimage\/.*\Z/

  has_attached_file :photo_two, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: "/images/:style/missing.png"
  validates_attachment_content_type :photo_two, content_type: /\Aimage\/.*\Z/

  has_attached_file :photo_three, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: "/images/:style/missing.png"
  validates_attachment_content_type :photo_three, content_type: /\Aimage\/.*\Z/

  has_attached_file :photo_four, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: "/images/:style/missing.png"
  validates_attachment_content_type :photo_four, content_type: /\Aimage\/.*\Z/

  has_attached_file :photo_five, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: "/images/:style/missing.png"
  validates_attachment_content_type :photo_five, content_type: /\Aimage\/.*\Z/

  before_validation(on: :create) do
    self.make_slug
  end

  def make_slug
    slug = self.title.downcase
    slug.gsub!(',' '')
    slug.gsub!("'", "")
    slug.gsub!('.', '')
    slug.gsub!(' ', '-')
    self.slug = slug
  end

  def calc_end_time
    return self.end_time.strftime('%l:%M %P on %B %d, %Y')
  end

  def percent_discount
    return 1 - (self.discount.to_f/self.price.to_f)
  end

  def self.expire_product
    products = Product.where('status = ? AND end_time <= ?', 'live', Time.now)
    products.each do |product|
      product_orders = 0
      product.commits.each do |commit|
        product_orders += commit.amount.to_i*product.discount.to_f
        commit.status = 'past'
        commit.save
      end
      if product_orders >= product.milestones[0].goal.to_i
        product.status = 'goal_met'
        product.save
      else
        product.status = 'needs_attention'
        product.save
      end
    end
  end

end
