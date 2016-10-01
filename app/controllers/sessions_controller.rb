class SessionsController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def create
  user = User.find_by_email(params[:email].downcase)
    if !user
      flash[:error] = "No users found with this email"
      return redirect_to users_path
    elsif user && user.authenticate(params[:password])

      if user.is_retailer?
        session[:user_id] = user.id
        # if user.retailer.needs_credit_card?
        #   return redirect_to '/retailer/accounts'
        # elsif user.retailer.needs_shipping_info?
        #   return redirect_to '/retailer/shipping_addresses'
        # elsif user.retailer.card_declined?
        #   return redirect_to "/retailer/#{user.retailer.declined_order}/card_declined"
        # else
          return redirect_to '/shop'
        # end

      elsif user.is_wholesaler?
        if user.wholesaler.approved
          session[:user_id] = user.id
          return redirect_to '/wholesaler/profile'
        else
          flash[:error] = "Sorry, your application has not been accepted yet."
          return redirect_to '/users'
        end
      else
        session[:user_id] = user.id
        return redirect_to '/admin'
      end

    else
      flash[:error] = "Incorrect password"
      return redirect_to users_path
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to users_path
  end

end
