require 'Util'
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  # before_action :check_for_email_click
  include ApplicationHelper

  private
  def check_for_email_click
    if !params[:email_click].nil?
      user = User.find_by_uuid(params[:email_click])
      if !user.nil?
        return session[:user_id] = user.id
      else
        return redirect_to "/users"
      end
    else
      return redirect_to "/users"
    end
  end

end
