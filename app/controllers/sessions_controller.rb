class SessionsController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def create
  user = User.find_by_email(params[:email].downcase)
    if !user
      flash[:error] = "No users found with this email"
      redirect_to users_path
    elsif user && user.authenticate(params[:password])
      session[:user_id] = user.id

      if user.is_retailer?
        if user.retailer.needs_credit_card?
          redirect_to '/retailer/accounts'
        elsif user.retailer.needs_shipping_info?
          redirect_to '/retailer/shipping_addresses'
        else
          redirect_to '/shop'
        end

      elsif user.is_wholesaler?
        redirect_to '/wholesaler/profile'
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
