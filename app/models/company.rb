class Company < ActiveRecord::Base
  before_save :strip_fields

  validates :company_name, presence: true

  belongs_to :user

  has_attached_file :logo, styles: {large: "600x400", medium: "450x300", thumb: "300x200" }, :s3_protocol => 'https'
  validates_attachment_content_type :logo, content_type: /\Aimage\/.*\Z/

  before_create(on: :save) do
    # self.company_key = create_company_key
    self.uuid = SecureRandom.uuid
  end

  def create_company_key
    key = self.company_name.gsub(' ', '-').downcase
    key = key.gsub('.', '')
    key = key.gsub(',', '')
    key = key.gsub('!', '')
    key = key.gsub("'", "")
    return key
  end

  def strip_fields
    self.company_name = self.company_name.strip
    self.location = self.location.strip if !self.location.nil?
    self.website = self.website.strip if !self.website.nil?
    self.company_key = self.create_company_key
    # self.save!
  end

  def ratings
    return self.user.wholesaler.ratings.where('comment is not null')
  end

end
