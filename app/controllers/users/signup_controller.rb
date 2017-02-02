class Users::SignupController < UsersController

  def step1
    if params[:referral_code]
      referral = Referral.find_by(:referral_code => params[:referral_code])
      if !referral.nil?
        session[:referral_code] = params[:referral_code]
      end
      redirect_to '/signup/step1'
    end
    if request.post?
      user = User.create(user_params)
      if user.save
        check_for_referral
        company = Company.create(company_params)
        company.user_id = user.id
        company.save(validate: false)
        retailer = Retailer.new
        retailer.user_id = user.id
        retailer.save!
        BlueBirdEmail.new_application(user)
        return redirect_to "/thank_you?_user=#{user.first_name}"
      else
        flash[:error] = user.errors.full_messages.join('<br>').html_safe
        return redirect_to request.referrer
      end
    end
  end

  def check_for_referral
    if session[:referral_code]
      referral = Referral.find_by(:referral_code => session[:referral_code])
      referral.update_column(:signed_up, true)
      session[:referral_code] = nil
    end
  end

  def step2
    redirect_to '/signup/step1' if params[:uuid].nil?
    @company = Company.find_by_uuid(params[:uuid])
    if request.post?
      user = User.create(user_params)
      if user.save
        @company.user_id = user.id
        @company.save(validate: false)
        retailer = Retailer.new
        retailer.user_id = user.id
        retailer.save!
        BlueBirdEmail.new_application(user)
        return redirect_to "/thank_you?_user=#{user.first_name}"
      else
        flash[:error] = user.errors.full_messages
        return redirect_to request.referrer
      end
    end
  end

  private
  def user_params
    params.require(:user).permit(:first_name, :last_name, :phone_number, :email, :password, :password_confirmation)
  end

  def company_params
    params.require(:company).permit(:company_name, :location)
  end

end
