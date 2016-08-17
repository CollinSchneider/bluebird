require "net/http"
require "uri"
class UsersController < ApplicationController

  BETA_CODE = "Red_Robin4370"

  def index
    if !current_user.nil?
      if current_user.user_type == 'wholesaler'
        redirect_to wholesaler_path
      elsif current_user.user_type == 'retailer'
        redirect_to retailer_path
      end
    end
  end

  def signup
  end

  def reset_password
    @user = User.find_by_password_reset_token(params[:token])
  end

  def password_reset
    @user = User.find(params[:id])
    @user.update(user_params)
    @user.save(validate: false)
    binding.pry
    if @user.save(validate: false)
      session[:user_id] = @user.id
      @user.password_reset_token = nil
      @user.password_reset_expiration = nil
      @user.save
      binding.pry
      redirect_to shop_path
    else
      redirect_to request.referrer
      flash.now[:error] = @user.errors
    end
    binding.pry
  end

  def show
    @user = User.find(params[:id])
  end

  def create
    if params[:beta_code] == BETA_CODE
      user = User.create(user_params)
      if user.save
        session[:user_id] = user.id
        user.create_key
        user.create_uuid
        if user.user_type == 'retailer'
          user.make_stripe_customer
          Mailer.retailer_welcome_email(user).deliver_later
          redirect_to shop_path
        elsif user.user_type == 'wholesaler'
          Mailer.wholesaler_welcome_email(user).deliver_later
          redirect_to wholesaler_path
        end
      else
        flash[:error] = user.errors.full_messages
        redirect_to request.referrer
      end
    else
      redirect_to request.referrer
      flash[:error] = "Incorrect Beta Code!"
    end
  end

  def update
    user = User.find(params[:id])
    user.update(user_params)
    redirect_to request.referrer
  end

  def destroy
    user = User.find(params[:id])
    session.destroy
    user.destroy
    redirect_to root_path
  end

  def logout
    session.destroy
    redirect_to '/users'
  end

  # def retailer
  # end
  #
  # def wholesaler
  # end

  def accounts
    Stripe.api_key = ENV["STRIPE_SECRET_KEY"]
    @stripe_customer = Stripe::Customer.retrieve(current_user.retailer_stripe_id)
  end

  def accounts_verify
    scope = params[:scope]
    auth_code = params[:code]

    uri = URI.parse("https://connect.stripe.com/oauth/token")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(uri.request_uri)
    request.set_form_data({
      "client_secret" => "sk_test_TI9EamOjFwLiHOvvNF6Q1cIn",
      "code" => auth_code,
      "grant_type" => "authorization_code"
    })
    response = http.request(request)
    data = JSON.parse(response.body)

    credential = StripeCredential.new
    credential.stripe_publishable_key = data["stripe_publishable_key"]
    credential.access_token = data["access_token"]
    credential.stripe_user_id = data["stripe_user_id"]
    credential.user_id = current_user.id
    credential.save!

    Stripe.api_key = ENV['STRIPE_SECRET_KEY']
    customer = Stripe::Customer.create(
      {:description => "Customer for: #{current_user.email}"},
      {:stripe_account => credential.stripe_user_id}
    )

    redirect_to wholesaler_path
  end

  def settings
    authenticate_anybody
  end

  private
  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :password,
      :user_type, :wholesaler_stripe_id, :retailer_stripe_id, :company_name,
      :contactable, :phone_number, :password_reset_token, :password_reset_expiration, :key)
  end

end
