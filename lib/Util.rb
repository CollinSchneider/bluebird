class Util

  def slug(string)
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

end
