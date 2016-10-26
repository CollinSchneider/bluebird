class Api::WholesalersController < ApiController

  def update_account
    current_user.editing_user_info = true
    if current_user.update(update_user_params)
      current_user.wholesaler.save!
      flash[:success] = "Updated Info Successfully"
      return redirect_to request.referrer
    else
      flash[:error] = current_user.errors.full_messages
      flash[:notice] = "Email is already taken, or all fields must be filled out completely." if current_user.errors.empty?
      return redirect_to request.referrer
    end
  end

  private
  def update_user_params
    params.require(:user).permit(:first_name, :last_name, :email, :password,
      :contactable, :phone_number)
  end

end
