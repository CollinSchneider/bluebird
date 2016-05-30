class UsersController < ApplicationController

  def index
    if current_user
      if current_user.user_type == 'wholesaler'
        redirect_to wholesaler_path
      elsif current_user.user_type == 'retailer'
        redirect_to retailer_path
      end
    end
  end

  def show
    @user = User.find(params[:id])
  end

  def create
    user = User.create(user_params)
    if user.save
      session[:user_id] = user.id
      if user.user_type == 'retailer'
        user.make_stripe_customer
        redirect_to shop_path
      elsif user.user_type == 'wholesaler'
        user.make_stripe_customer
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

  def accounts
    Stripe.api_key = ENV["STRIPE_SECRET_KEY"]
    @stripe_customer = Stripe::Customer.retrieve(current_user.stripe_customer_id)
  end

  private
  def user_params
    params.require(:user).permit(:email, :password, :user_type, :stripe_customer_id)
  end

end
