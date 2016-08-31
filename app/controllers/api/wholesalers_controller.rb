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
        #TODO thanks for applying email
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
      #TODO  congrats on being accepted email
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

  def update_account
    current_user.update(update_user_params)
    current_user.skip_password_presence = true
    if params[:contactable_by_email] == 'true'
      current_user.wholesaler.contactable_by_email = true
    else
      current_user.wholesaler.contactable_by_email = false
    end
    if params[:contactable_by_phone] == 'true'
      current_user.wholesaler.contactable_by_phone = true
    else
      current_user.wholesaler.contactable_by_phone = false
    end
    if current_user.save(validate: false)
      current_user.wholesaler.save(validate: false)
      flash[:success] = "Updated Info Successfully"
    else
      flash[:error] = current_user.errors.full_messages
    end
    binding.pry
    redirect_to request.referrer
  end

  private
  def update_user_params
    params.require(:user).permit(:first_name, :last_name, :email, :password,
      :contactable, :phone_number, :password_reset_token, :password_reset_expiration)
  end

end
