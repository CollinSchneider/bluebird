class Users::ApplyController < UsersController
  layout 'onboarding'

  def step1
    if request.post?
      company = Company.create(company_params)
      if company.save
        return redirect_to "/apply/step2?uuid=#{company.uuid}"
      else
        flash[:error] = company.errors.full_messages
        return redirect_to request.referrer
      end
    end
  end

  def step2
    redirect_to '/apply/step1' if params[:uuid].nil?
    @company = Company.find_by_uuid(params[:uuid])
    if request.post?
      user = User.new
      user.editing_user_info = true
      user.update(user_params)
      if user.save
        @company.user_id = user.id
        @company.save(validate: false)
        wholesaler = Wholesaler.new
        wholesaler.user_id = user.id
        wholesaler.approved = false
        wholesaler.contactable_by_phone = false
        wholesaler.contactable_by_email = false
        wholesaler.save!
        return redirect_to "/thank_you?_user=#{user.first_name}"
      else
        flash[:error] = user.errors.full_messages
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
        return redirect_to "/thank_you?_user=#{@user.first_name}"
      else
        flash[:error] = @user.errors.full_messages
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

  def step_1_params
    params.require(:user).permit(:first_name, :last_name, :email, )
  end

end
