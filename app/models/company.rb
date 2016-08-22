class Company < ActiveRecord::Base

  belongs_to :user

  has_attached_file :logo, styles: {large: "600x900!", medium: "400x600!", thumb: "200x300!" }, default_url: "/images/:style/missing.png"
  validates_attachment_content_type :logo, content_type: /\Aimage\/.*\Z/

  before_create(on: :save) do
    self.company_key = create_company_key
  end

  def create_company_key
    key = self.company_name.gsub(' ', '-').downcase
    key = key.gsub('.', '')
    key = key.gsub(',', '')
    key = key.gsub('!', '')
    key = key.gsub("'", "")
    return key
  end

end
