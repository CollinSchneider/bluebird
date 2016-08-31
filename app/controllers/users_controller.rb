require "net/http"
require "uri"
class UsersController < ApplicationController

  BETA_CODE = "Red_Robin4370"

  def index
    redirect_if_logged_in
  end

  def signup
  end

  def reset_password
    @user = User.find_by_password_reset_token(params[:token])
  end

  def password_reset
    @user = User.find(params[:id])
    @user.update(user_params)
    if @user.save(validate: false)
      session[:user_id] = @user.id
      @user.password_reset_token = nil
      @user.password_reset_expiration = nil
      @user.save
      redirect_to shop_path
    else
      redirect_to request.referrer
      flash.now[:error] = @user.errors
    end
  end

  def show
    @user = User.find(params[:id])
  end

  def create
    if params[:beta_code] == BETA_CODE
      if params[:user][:password] == params[:user][:password_confirmation]
        user = User.create(user_params)
        if user.save
          session[:user_id] = user.id
            admin = Admin.new
            admin.user_id = user.id
            admin.save
            # company = Company.new
            # company.company_name = params[:company][:company_name]
            # company.user_id = user.id
            # company.save
          # if params[:user_type] == 'retailer'
          #   retailer = Retailer.new
          #   retailer.user_id = user.id
          #   retailer.save
          #   # Mailer.retailer_welcome_email(user).deliver_later
          #   redirect_to '/retailer/accounts'
          # elsif params[:user_type] == 'wholesaler'
          #   wholesaler = Wholesaler.new
          #   wholesaler.user_id = user.id
          #   wholesaler.save
          #   # Mailer.wholesaler_welcome_email(user).deliver_later
          #   redirect_to '/wholesaler/profile'
          # end
        else
          flash[:error] = user.errors.full_messages
          redirect_to request.referrer
        end
      else
        redirect_to request.referrer
        flash[:error] = ["Password and Password Confirmation does not match"]
      end
    else
      redirect_to request.referrer
      flash[:error] = ["Incorrect Beta Code!"]
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

    stripe_publishable_key = data["stripe_publishable_key"]
    access_token = data["access_token"]
    stripe_user_id = data["stripe_user_id"]
    wholesaler = current_user.wholesaler
    wholesaler.stripe_id = stripe_user_id
    wholesaler.save!

    Stripe.api_key = ENV['STRIPE_SECRET_KEY']
    customer = Stripe::Customer.create(
      {:description => "Customer for: #{current_user.full_name}"},
      {:stripe_account => current_user.wholesaler.stripe_id}
    )

    redirect_to '/wholesaler/profile'
  end

  def settings
    authenticate_anybody
  end

  private
  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :password,
      :contactable_by_phone, :contactable_by_email, :phone_number,
      :password_reset_token, :password_reset_expiration)
  end

  def redirect_if_logged_in
    return redirect_to '/shop' if !current_user.nil?
  end

end
