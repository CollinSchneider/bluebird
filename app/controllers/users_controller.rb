require "net/http"
require "uri"
class UsersController < ApplicationController

  BETA_CODE = "Red_Robin4370"

  def index
    redirect_if_logged_in
  end

  def why
    redirect_if_logged_in
  end

  def reset_password
    @user = User.find_by_password_reset_token(params[:token])
  end

  def password_reset
    @user = User.find(params[:id])
    @user.update(user_params)
    if @user.save
      session[:user_id] = @user.id
      @user.password_reset_token = nil
      @user.password_reset_expiration = nil
      @user.save!
      return redirect_to "/shop"
    else
      flash[:error] = @user.errors.full_messages
      return redirect_to request.referrer
    end
  end

  def show
    @user = User.find(params[:id])
  end

  def update
    user = User.find(params[:id])
    # user.skip_password_presence = true
    user.attributes = user_params
    if user.save(context: :user_info_create)
      flash[:success] = "Info Updated"
      return redirect_to request.referrer
    else
      flash[:error] = user.errors.full_messages
      return redirect_to request.referrer
    end
  end

  def destroy
    user = User.find(params[:id])
    session.destroy
    user.destroy
    return redirect_to "/users"
  end

  def logout
    session.destroy
    return redirect_to '/users'
  end

  def accounts_verify
    scope = params[:scope]
    auth_code = params[:code]

    if !auth_code.nil? && !scope.nil?
      uri = URI.parse("https://connect.stripe.com/oauth/token")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Post.new(uri.request_uri)
      request.set_form_data({
        "client_secret" => ENV['STRIPE_SECRET_KEY'],
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

      return redirect_to '/wholesaler/profile'
    end
  end

  private
  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :password,
      :contactable_by_phone, :contactable_by_email, :phone_number,
      :password_reset_token, :password_reset_expiration, :password_confirmation)
  end

  def redirect_if_logged_in
    return redirect_to '/shop' if !current_user.nil?
  end

end
