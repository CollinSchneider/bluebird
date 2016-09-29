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
    return Rails.env == development ? 'http://localhost:3000' : 'https://bluebirdclub.herokuapp.com'
  end

end
