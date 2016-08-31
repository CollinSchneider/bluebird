class Users::SignupController < UsersController

  def step1
    if request.post?
      user = User.create(step_1_params)
      if user.save(validate: false)
        redirect_to "/signup/step2?uuid=#{user.uuid}"
      end
    end
  end

  def step2
    redirect_if_company_present
    redirect_to '/signup/step1' if params[:uuid].nil?
    @user = User.find_by_uuid(params[:uuid])
    if request.post?
      @user.phone_number = params[:phone_number]
      company = Company.new
      company.company_name = params[:company_name]
      # company.website = params[:website]
      # company.bio = params[:bio]
      company.user_id = @user.id
      if company.save!
        @user.save(validate: false)
        redirect_to "/signup/step3?uuid=#{@user.uuid}"
      else
        flash[:error] = company.errors
        redirect_to request.referrer
      end
    end
  end

  def step3
    redirect_to '/signup/step1' if params[:uuid].nil?
    @user = User.find_by_uuid(params[:uuid])
    if request.post?
      @user.update(user_params)
      if @user.save
        Mailer.retailer_welcome_email(@user, params[:user][:password])
        retailer = Retailer.new
        retailer.user_id = @user.id
        retailer.save
        # Mailer.wholesaler_welcome_email(@user).deliver_later
        session[:user_id] = @user.id
        return redirect_to "/shop"
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

  def redirect_if_company_present
    @user = User.find_by_uuid(params[:uuid])
    redirect_to "/signup/step3?uuid=#{params[:uuid]}" if @user.company.present?
  end

end
