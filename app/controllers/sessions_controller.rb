class SessionsController < ApplicationController

  def create
  user = User.find_by_email(params[:email])
    if !user
      flash[:error] = "No users found with this email"
      redirect_to users_path
    elsif user && user.authenticate(params[:password])
      session[:user_id] = user.id
      if user.user_type == 'retailer'
        redirect_to products_path
      elsif user.user_type == 'wholesaler'
        redirect_to wholesaler_path
      end
    else
      flash[:error] = "Incorrect password"
      redirect_to users_path
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to users_path
  end

end
