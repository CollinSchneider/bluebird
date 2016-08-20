class Api::WholesalersController < ApiController

  def apply
    if params[:user][:password] == params[:user][:password_confirmation]
      user = User.create(user_params)
      if user.save
        company = Company.new
        company.company_name = params[:company][:company_name]
        company.website = params[:company][:website]
        company.user_id = user.id
        company.save
        wholesaler = Wholesaler.new
        wholesaler.approved = false
        wholesaler.user_id = user.id
        wholesaler.save
        # Mailer.wholesaler_welcome_email(user).deliver_later
        redirect_to "/thank_you?_user=#{user.first_name}"
      else
        flash[:error] = user.errors.full_messages
        redirect_to request.referrer
      end
    else
      redirect_to request.referrer
      flash[:error] = ["Password and Password Confirmation does not match"]
    end
  end

  def approve
    wholesaler = Wholesaler.find(params[:id])
    wholesaler.approved = true
    if wholesaler.save
      render :json => {
        success: true,
        message: "Approved #{wholesaler.user.company.company_name}"
      }
    else
      render :json => {
        success: false,
        message: "Error: #{wholesaler.user.company.company_name} could not be approved"
      }
    end
  end

  private
  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :password,
      :contactable, :phone_number, :password_reset_token, :password_reset_expiration)
  end

end
