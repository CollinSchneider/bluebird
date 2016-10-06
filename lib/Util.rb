class Util

  def self.slug(string)
    slug = string.downcase
    slug.gsub!(',' '')
    slug.gsub!("'", "")
    slug.gsub!('.', '')
    slug.gsub!(' ', '-')
    return slug
  end

  def generate_token
    return SecureRandom.uuid
  end

  def self.current_environment
    return "http://localhost:3000" if Rails.env == "development"
    return "http://bluebirdclub.herokuapp.com" if Rails.env == "production"
  end

  def self.bluebird_logo_url
    return "https://s3.amazonaws.com/bluebird-club/logos/bluebird-logo.png?X-Amz-Date=20161006T192508Z&X-Amz-Expires=300&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Signature=d3684a25e67a47c5f2db076f48f3280564ccd70a1f0536d1059a5fd2e55b13f9&X-Amz-Credential=ASIAJFLWDJJOOC23CRYQ/20161006/us-east-1/s3/aws4_request&X-Amz-SignedHeaders=Host&x-amz-security-token=FQoDYXdzENz//////////wEaDIbN9AlqV/%2BcI34NNSL6ARW/Wgzfe3eVYtii7gb2TPveTJ1vu780m3yTF/71GmF82RIWzgA3IXt5u9IfzrufZpuB75ZIVZwBy6cbfDY/RAB3ZBHD9p6uN%2BWG4SxfG0uYl5Dpp1R4zClvz/c6qUj9Lemoi759rDdlHtGd0lgFPmUC7cqcj%2BrnbekDBsJ/fbsYFHzY/MIk//1uMsAbfkjRjvQhqcyy4qDHeC11AE2WcrOXSbDnN7s1TJW8VYswahrrq9t5G/FwvCrWlBU%2Bcm1SIGE8XiP6tsSLrBzuwQOklZBBdv0X%2BJc3y1Gs9VFNBJ9Q1Il%2BzGIZBM7n7BEjD8f9ZvtL6QJWgDmw1NMo3MXavwU%3D"
  end

end
