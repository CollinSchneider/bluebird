class AdminController < ApplicationController
  before_action :redirect_if_not_logged_in
  before_action :redirect_if_not_admin
  layout 'admin'

  def index
    @admin = current_user.admin
    @applications = Wholesaler.where('approved != ? OR approved IS NULL', true)
  end

  def feature_products
    @products = Product.where('status = ? AND end_time > ?', 'live', Time.now)
  end

  def unshipped
    orders = Commit.where("sale_made = 't' AND has_shipped = 'f' AND refunded = 'f'")
    if params[:query]
      @orders = orders.where('uuid = ?', params[:query]).order(updated_at: :asc)
    else
      @orders = orders.order(updated_at: :asc)
    end
  end

  private
  def redirect_if_not_logged_in
    redirect_to '/users' if current_user.nil?
  end

  def redirect_if_not_admin
    redirect_to '/shop' if current_user.is_retailer?
    redirect_to '/wholesaler/profile' if current_user.is_wholesaler?
  end

end
