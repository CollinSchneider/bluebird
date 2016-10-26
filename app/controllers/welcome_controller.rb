require 'stripe'
class WelcomeController < ApplicationController
  before_action :redirect_if_not_logged_in

  def shop
    if params[:products] == 'discounted'
      @products = Product.where('status = ? AND end_time > ? AND CAST(current_sales AS decimal) >= CAST(products.goal AS decimal)', 'live', Time.current).page(params[:page]).per_page(6)
    elsif params[:query]
      @products = Product.queried_products(params[:query]).page(params[:page]).per_page(6)
    elsif params[:products] == 'percent_off'
      @products = Product.where('status = ? AND end_time > ?', 'live', Time.current).order(percent_discount: :desc).page(params[:page]).per_page(6)
    # TODO: NEED SQL JOIN TO PULL AVERAGE SKU PRICE
    # elsif params[:products] == 'high_low'
    #   @products = Product.where('status = ?', 'live').order(discount: :desc).page(params[:page]).per_page(6)
    # elsif params[:products] == 'low_high'
    #   Product.where('status = ?', 'live')
    #   @products = Product.where('status = ?', 'live').order(discount: :asc).page(params[:page]).per_page(6)
    else
      @products = Product.where('status = ?', 'live').page(params[:page]).per_page(6)
    end
  end

  def ending_soon
    if params[:products] == 'discounted'
      @products = Product.where('status = ? AND end_time > ? AND current_sales >= products.goal', 'live', Time.current).order(end_time: :asc).page(params[:page]).per_page(6)
    elsif params[:query]
      @products = Product.queried_products(params[:query]).order(end_time: :asc).page(params[:page]).per_page(6)
    else
      @products = Product.where('status = ? AND end_time > ?', 'live', Time.current).order(end_time: :asc).page(params[:page]).per_page(6)
    end
  end

  def new_arrivals
    if params[:products] == 'discounted'
      @products = Product.where('status = ? AND end_time > ? AND current_sales >= products.goal', 'live', Time.current).order(start_time: :asc).page(params[:page]).per_page(6)
    elsif params[:query]
      @products = Product.queried_products(params[:query]).order(start_time: :desc).page(params[:page]).per_page(6)
    else
      @products = Product.where('status = ? AND end_time > ?', 'live', Time.current).order(start_time: :desc).page(params[:page]).per_page(6)
    end
  end

  def best_sellers
    if params[:products] == 'discounted'
      @products = Product.where('status = ? AND end_time > ? AND current_sales >= products.goal', 'live', Time.current).order(current_sales: :desc).page(params[:page]).per_page(6)
    elsif params[:query]
      @products = Product.queried_products(params[:query]).order(current_sales: :desc).page(params[:page]).per_page(6)
    else
      @products = Product.where('status = ? AND end_time > ?', 'live', Time.current).order(current_sales: :desc).page(params[:page]).per_page(6)
    end
  end

  def tech
    if params[:products] == 'discounted'
      @products = Product.where('status = ? AND end_time > ? AND current_sales >= products.goal AND category = ?', 'live', Time.current, 'Tech').page(params[:page]).per_page(6)
    elsif params[:query]
        @products = Product.category_queried_products(params[:query], 'Tech').page(params[:page]).per_page(6)
    elsif params[:products] == 'percent_off'
      @products = Product.where('status = ? AND end_time > ? AND category = ?', 'live', Time.current, 'Tech').order(percent_discount: :desc).page(params[:page]).per_page(6)
    else
      @products = Product.where('status = ? AND category = ?', 'live', 'Tech').page(params[:page]).per_page(6)
    end
  end

  def accessories
    if params[:products] == 'discounted'
      @products = Product.where('status = ? AND end_time > ? AND current_sales >= products.goal AND category = ?', 'live', Time.current, 'Accessories').page(params[:page]).per_page(6)
    elsif params[:query]
      @products = Product.category_queried_products(params[:query], 'Accessories').page(params[:page]).per_page(6)
    elsif params[:products] == 'percent_off'
      @products = Product.where('status = ? AND end_time > ? AND category = ?', 'live', Time.current, 'Accessories').order(percent_discount: :desc).page(params[:page]).per_page(6)
    else
      @products = Product.where('status = ? AND category = ?', 'live', 'Accessories').page(params[:page]).per_page(6)
    end
  end

  def home_goods
    if params[:products] == 'discounted'
      @products = Product.where('status = ? AND end_time > ? AND current_sales >= products.goal AND category = ?', 'live', Time.current, 'Home Goods').page(params[:page]).per_page(6)
    elsif params[:query]
      @products = Product.category_queried_products(params[:query], 'Home Goods').page(params[:page]).per_page(6)
    elsif params[:products] == 'percent_off'
      @products = Product.where('status = ? AND end_time > ? AND category = ?', 'live', Time.current, 'Home Goods').order(percent_discount: :desc).page(params[:page]).per_page(6)
    else
      @products = Product.where('status = ? AND category = ?', 'live', 'Home Goods').page(params[:page]).per_page(6)
    end
  end

  def apparel
    if params[:products] == 'discounted'
      @products = Product.where('status = ? AND end_time > ? AND current_sales >= products.goal AND category = ?', 'live', Time.current, 'Apparel').page(params[:page]).per_page(6)
    elsif params[:query]
      @products = Product.category_queried_products(params[:query], 'Apparel').page(params[:page]).per_page(6)
    elsif params[:products] == 'percent_off'
      @products = Product.where('status = ? AND end_time > ? AND category = ?', 'live', Time.current, 'Apparel').order(percent_discount: :desc).page(params[:page]).per_page(6)
    else
      @products = Product.where('status = ? AND category = ?', 'live', 'Apparel').page(params[:page]).per_page(6)
    end
  end

  def company_show
    @company = Company.find_by(:company_key => params[:key], :id => params[:id])
    return redirect_to '/shop' if @company.nil?
    @products = Product.where('wholesaler_id = ? AND status = ? AND end_time >= ?', @company.user.wholesaler.id, 'live', Time.current)
  end

  def regularly_priced
    @products = Product.where('id in (
      select product_id from product_tokens where expiration_datetime > ?
    )', Time.current).page(params[:page]).per_page(6)
  end

end
