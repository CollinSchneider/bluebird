require 'Util'
require 'BlueBirdEmail'
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  # before_action :check_for_email_click
  include ApplicationHelper
  before_action :set_title

  private
  def set_title
    @title ||= "BlueBird.club"
  end

  def redirect_if_not_logged_in
    if current_user.nil?
      session[:redirect_url] = request.fullpath
      return redirect_to "/users"
    end
  end

end
