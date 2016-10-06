require 'Util'
require 'BlueBirdEmail'
require 'sendgrid-ruby'
include SendGrid
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  # before_action :check_for_email_click
  include ApplicationHelper

  private
  def redirect_if_not_logged_in
    return redirect_to "/users?redirect_url=#{request.fullpath}" if current_user.nil?
  end

end
