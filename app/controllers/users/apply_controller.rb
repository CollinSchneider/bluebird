class Users::ApplyController < UsersController
  layout 'onboarding'

  def step1
    if request.post?
      user = User.create(user_params)
      if user.save
        company = Company.create(company_params)
        company.user_id = user.id
        company.save!
        stat = WholesalerStat.new
        stat.save!
        wholesaler = Wholesaler.new
        wholesaler.user_id = user.id
        wholesaler.wholesaler_stat = stat
        wholesaler.save!
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
    params.require(:company).permit(:bio, :website, :company_name, :location)
  end

end
