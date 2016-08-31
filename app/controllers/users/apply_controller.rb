class Users::ApplyController < UsersController
  layout 'onboarding'

  def step1
    if request.post?
      user = User.create(step_1_params)
      if user.save(validate: false)
        return redirect_to "/apply/step2?uuid=#{user.uuid}"
      else
        flash[:error] = user.errors.full_messages
        return redirect_to request.referrer
      end
    end
  end

  def step2
    redirect_to '/apply/step1' if params[:uuid].nil?
    @user = User.find_by_uuid(params[:uuid])
    if request.post?
      @user.phone_number = params[:phone_number]
      company = Company.new
      company.company_name = params[:company_name]
      company.website = params[:website]
      company.bio = params[:bio]
      company.user_id = @user.id
      if company.save!
        @user.save(validate: false)
        return redirect_to "/apply/step3?uuid=#{@user.uuid}"
      else
        flash[:error] = company.errors
        return redirect_to request.referrer
      end
    end
  end

  def step3
    redirect_to '/apply/step1' if params[:uuid].nil?
    @user = User.find_by_uuid(params[:uuid])
    if request.post?
      @user.update(user_params)
      if @user.save
        wholesaler = Wholesaler.new
        wholesaler.user_id = @user.id
        wholesaler.save
        Mailer.wholesaler_welcome_email(@user, params[:user][:password]).deliver_later
        return redirect_to "/thank_you?_user=#{@user.first_name}"
      else
        flash[:error] = @user.errors.full_messages
        return redirect_to request.referrer
      end
    end
  end

  private
  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end

  def step_1_params
    params.require(:user).permit(:first_name, :last_name)
  end

end
