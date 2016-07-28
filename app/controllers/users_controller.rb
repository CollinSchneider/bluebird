require "net/http"
require "uri"
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
        redirect_to wholesaler_path
      end
    else
      flash[:error] = user.errors.full_messages
      redirect_to request.referrer
    end
  end

  def update
    user = User.find(params[:id])
    user.update(user_params)
    redirect_to request.referrer
  end

  def retailer
  end

  def wholesaler
  end

  def accounts
    Stripe.api_key = ENV["STRIPE_SECRET_KEY"]
    @stripe_customer = Stripe::Customer.retrieve(current_user.retailer_stripe_id)
  end

  def accounts_verify
    code = params[:code]
    scope = params[:scope]

    auth_code = params[:code]
    uri = URI.parse("https://connect.stripe.com/oauth/token")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(uri.request_uri)
    request.set_form_data({
      "client_secret" => ENV["STRIPE_SECRET_KEY"],
      "code" => auth_code,
      "grant_type" => "authorization_code"
    })
    response = http.request(request)
    data = JSON.parse(response.body)
    current_user.update(:wholesaler_stripe_id => data["stripe_user_id"])
    current_user.save!
    # render :json => {:data => data}
    redirect_to wholesaler_path
  end

  private
  def user_params
    params.require(:user).permit(:email, :password, :user_type, :wholesaler_stripe_id, :retailer_stripe_id)
  end

end
