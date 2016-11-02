class AdminController < ApplicationController
  before_action :redirect_if_not_logged_in
  before_action :redirect_if_not_admin
  layout 'admin'

  def wholesalers
    @title = "Pending Wholesalers"
    @admin = current_user.admin
    @applications = Wholesaler.where('user_id in (select id from users where approved != ?)', true)
  end

  def retailers
    @title = "Pending Retailers"
    @admin = current_user.admin
    @applications = Retailer.where('user_id in (select id from users where approved != ?)', true)
  end

  def feature_products
    @title = "Feature Products"
    @products = Product.where('status = ? AND end_time > ?', 'live', Time.current)
  end

  def unshipped
    @title = "Unshipped Orders"
    orders = Commit.where("sale_made = 't' AND has_shipped = 'f' AND refunded = 'f'")
    if params[:query]
      @orders = orders.where('uuid = ?', params[:query]).order(updated_at: :asc)
    else
      @orders = orders.order(updated_at: :asc)
    end
  end

  private
  def redirect_if_not_admin
    redirect_to '/shop' if current_user.is_retailer?
    redirect_to '/wholesaler/profile' if current_user.is_wholesaler?
  end

end
