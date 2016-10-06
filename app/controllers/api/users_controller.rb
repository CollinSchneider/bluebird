class Api::UsersController < ApiController

  def send_password_reset
    email = params[:email]
    user = User.find_by_email(email)
    if user
      token = SecureRandom.uuid
      user.password_reset_token = token
      user.password_reset_expiration = Time.now + 30.minutes
      user.save(validate: false)
      # BlueBirdEmail.forgot_password(user).deliver_later
      render :json => {message: "Instructions has been sent to #{email}, you have 30 minutes to reset your password."}
    else
      render :json => {message: "No users found with the email of #{email}."}
    end
  end

end
