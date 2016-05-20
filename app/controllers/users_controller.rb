class UsersController < ApplicationController

  def index
  end

  def create
    user = User.create(user_params)
    if user.save
      session[:user_id] = user.id
      if user.user_type == 'retailer'
        redirect_to products_path
      elsif user.user_type == 'wholesaler'
        redirect_to wholesaler_path
      end
    else
      flash[:error] = user.errors.full_messages
      redirect_to request.referrer
    end
  end

  def retailer
  end

  def wholesaler
  end

  private
  def user_params
    params.require(:user).permit(:email, :password, :user_type)
  end

end
