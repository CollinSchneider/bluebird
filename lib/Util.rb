class Util

  def self.slug(string)
    slug = string.downcase
    slug.gsub!(',' '')
    slug.gsub!("'", "")
    slug.gsub!('.', '')
    slug.gsub!(' ', '-')
    return slug
  end

  def self.test
    return "Is this working?"
  end

  def generate_token
    return SecureRandom.uuid
  end

  def self.current_environment
    return "http://localhost:3000" if Rails.env == "development"
    return "http://bluebirdclub-staging.herokuapp.com" if Rails.env == "bluebirdclub-staging"
    return "http://bluebirdclub.herokuapp.com" if Rails.env == "bluebirdclub"
  end

end
