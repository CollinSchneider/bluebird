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

  def regularly_priced
    @products = Product.where('id in (
      select product_id from product_tokens where expiration_datetime > ?
    )', Time.current).page(params[:page]).per_page(6)
  end

end
