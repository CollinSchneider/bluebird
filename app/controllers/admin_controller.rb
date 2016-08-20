class AdminController < ApplicationController
  before_action :redirect_if_not_admin
  layout 'admin'

  def index
    @admin = current_user.admin
    @applications = Wholesaler.where('approved != ? OR approved IS NULL', true)
  end

  private
  def redirect_if_not_admin
    redirect_to '/shop' if current_user.is_retailer?
    redirect_to '/wholesaler/profile' if current_user.is_wholesaler?
  end

end
