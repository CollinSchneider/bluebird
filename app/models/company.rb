class Company < ActiveRecord::Base

  belongs_to :user

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
