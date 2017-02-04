class ReferralGenerator

  def initialize(args)
    raise "Missing args" if args[:user_id].nil? || args[:referred_email].nil?
    @user_id = args[:user_id]
    @referred_email = args[:referred_email]
  end

  def perform!
    if !is_new_referral
      return {errors: ["Sorry, you've already referred this user."]}
    elsif !User.find_by(:email => @referred_email).nil?
      return {errors: ["This user is already signed up for BlueBird."]}
    else
      referral = Referral.create(
        :user_id => @user_id,
        :referred_email => @referred_email,
        :referral_code => create_code
      )
      if referral.save
        return {code: referral.referral_code}
      else
        return {errors: referral.errors}
      end
    end
  end

  private
  def create_code
    loop do
      code = SecureRandom.uuid
      return code unless Referral.find_by(:referral_code => code, :user_id => @user_id)
    end
  end

  def is_new_referral
    return Referral.find_by(:referred_email => @referred_email, :user_id => @user_id).nil? ? true : false
  end

end
