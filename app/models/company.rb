class Company < ActiveRecord::Base

  # validate :unique_company
  validates :company_name, presence: true

  belongs_to :user

  has_attached_file :logo, styles: {large: "600x300!", medium: "400x200!", thumb: "300x150!" }, default_url: "/images/:style/missing.png"
  validates_attachment_content_type :logo, content_type: /\Aimage\/.*\Z/

  before_create(on: :save) do
    self.company_key = create_company_key
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

  # VALIDATIONS
  def unique_company
    same_name = Company.find_by_company_key(self.company_key)
    if !same_name.nil?
      errors.add(:Another, "user already has this company name!")
    end
  end

end
