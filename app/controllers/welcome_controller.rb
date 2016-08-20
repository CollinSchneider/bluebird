require 'stripe'
class WelcomeController < ApplicationController
  before_action :redirect_if_not_logged_in

  def shop
    authenticate_anybody
    if params[:products] == 'discounted'
      @products = Product.where('status = ? AND end_time > ? AND CAST(current_sales AS decimal) >= CAST(products.goal AS decimal)', 'live', Time.now).page(params[:page]).per_page(3)
    elsif params[:query]
      query = params[:query]
      slug = query.downcase
      slug.gsub!(',' '')
      slug.gsub!("'", "")
      slug.gsub!('.', '')
      slug.gsub!(' ', '-')
      slug.gsub!('?', '')
      slug.gsub!('!', '')
      @products = Product.where('slug LIKE ? AND end_time > ? AND status = ?
                                OR LOWER(description) LIKE ? AND end_time > ? AND status = ?
                                OR user_id in (
                                  select id from users where key like ?
                                ) AND end_time > ? AND status = ?',
                                "%#{slug}%", Time.now, 'live',
                                "%#{slug}%", Time.now, 'live',
                                "%#{slug}%", Time.now, 'live').page(params[:page]).per_page(3)
    elsif params[:products] == 'percent_off'
      @products = Product.where('status = ? AND end_time > ?', 'live', Time.now).order(percent_discount: :desc).page(params[:page]).per_page(3)
    elsif params[:products] == 'high_low'
      # @products = Product.where('status = ? ORDER BY CAST(discount AS DECIMAL) DESC', 'live').page(params[:page]).per_page(3)
      # @products = Product.where('status = ?', 'live').order(discount: :desc).page(params[:page]).per_page(3)
      @products = Product.where('status = ?', 'live').page(params[:page]).per_page(3)
    elsif params[:products] == 'low_high'
      # @products = Product.where('status = ? ORDER BY CAST(discount AS DECIMAL) ASC', 'live').page(params[:page]).per_page(3)
      # @products = Product.where('status = ?', 'live').order(discount: :asc).page(params[:page]).per_page(3)
      @products = Product.where('status = ?', 'live').page(params[:page]).per_page(3)
    else
      @products = Product.where('status = ?', 'live').page(params[:page]).per_page(3)
    end
    Stripe.api_key = ENV['STRIPE_SECRET_KEY']
    if current_user.is_retailer? && current_user.retailer.stripe_id
      @stripe_customer = Stripe::Customer.retrieve(current_user.retailer.stripe_id)
    end
  end

  def ending_soon
    authenticate_anybody
    if params[:products] == 'discounted'
      @products = Product.where('status = ? AND end_time > ? AND current_sales >= products.goal', 'live', Time.now).order(end_time: :asc).page(params[:page]).per_page(3)
    elsif params[:query]
      query = params[:query]
      slug = query.downcase
      slug.gsub!(',' '')
      slug.gsub!("'", "")
      slug.gsub!('.', '')
      slug.gsub!(' ', '-')
      @products = Product.where('slug LIKE ? AND end_time > ? AND status = ?
                                OR LOWER(description) LIKE ? AND end_time > ? AND status = ?
                                OR user_id in (
                                  select id from users where key like ?
                                ) AND end_time > ? AND status = ?',
                                "%#{slug}%", Time.now, 'live',
                                "%#{slug}%", Time.now, 'live',
                                "%#{slug}%", Time.now, 'live',).order(end_time: :asc).page(params[:page]).per_page(3)
    else
      @products = Product.where('status = ? AND end_time > ?', 'live', Time.now).order(end_time: :asc).page(params[:page]).per_page(3)
    end
    Stripe.api_key = ENV['STRIPE_SECRET_KEY']
    if current_user.is_retailer? && current_user.retailer.stripe_id
      @stripe_customer = Stripe::Customer.retrieve(current_user.retailer.stripe_id)
    end
  end

  def new_arrivals
    authenticate_anybody
    if params[:products] == 'discounted'
      @products = Product.where('status = ? AND end_time > ? AND current_sales >= products.goal', 'live', Time.now).order(start_time: :asc).page(params[:page]).per_page(3)
    elsif params[:query]
      query = params[:query]
      slug = query.downcase
      slug.gsub!(',' '')
      slug.gsub!("'", "")
      slug.gsub!('.', '')
      slug.gsub!(' ', '-')
      @products = Product.where('slug LIKE ? AND end_time > ? AND status = ?
                                OR LOWER(description) LIKE ? AND end_time > ? AND status = ?
                                OR user_id in (
                                  select id from users where key like ?
                                ) AND end_time > ? AND status = ?',
                                "%#{slug}%", Time.now, 'live',
                                "%#{slug}%", Time.now, 'live',
                                "%#{slug}%", Time.now, 'live',).order(start_time: :asc).page(params[:page]).per_page(3)
    else
      @products = Product.where('status = ? AND end_time > ?', 'live', Time.now).order(start_time: :asc).page(params[:page]).per_page(3)
    end
    Stripe.api_key = ENV['STRIPE_SECRET_KEY']
    if current_user.is_retailer? && current_user.retailer.stripe_id
      @stripe_customer = Stripe::Customer.retrieve(current_user.retailer.stripe_id)
    end
  end

  def best_sellers
    authenticate_anybody
    if params[:products] == 'discounted'
      @products = Product.where('status = ? AND end_time > ? AND current_sales >= products.goal', 'live', Time.now).order(current_sales: :desc).page(params[:page]).per_page(3)
    elsif params[:query]
      query = params[:query]
      slug = query.downcase
      slug.gsub!(',' '')
      slug.gsub!("'", "")
      slug.gsub!('.', '')
      slug.gsub!(' ', '-')
      @products = Product.where('slug LIKE ? AND end_time > ? AND status = ?
                                OR LOWER(description) LIKE ? AND end_time > ? AND status = ?
                                OR user_id in (
                                  select id from users where key like ?
                                ) AND end_time > ? AND status = ?',
                                "%#{slug}%", Time.now, 'live',
                                "%#{slug}%", Time.now, 'live',
                                "%#{slug}%", Time.now, 'live').order(current_sales: :desc).page(params[:page]).per_page(3)
    else
      @products = Product.where('status = ? AND end_time > ?', 'live', Time.now).order(current_sales: :desc).page(params[:page]).per_page(3)
    end
  end

  def tech
    authenticate_anybody
    if params[:products] == 'discounted'
      # TODO: Come back to this, not sure when product becomes 'goal_met'
      @products = Product.where('status = ? AND end_time > ? AND current_sales >= products.goal AND category = ?', 'live', Time.now, 'Tech').page(params[:page]).per_page(3)
    elsif params[:query]
      # binding.pry
      query = params[:query]
      slug = query.downcase
      slug.gsub!(',' '')
      slug.gsub!("'", "")
      slug.gsub!('.', '')
      slug.gsub!(' ', '-')
      @products = Product.where('slug LIKE ? AND end_time > ? AND category = ? AND stauts = ?
                                OR LOWER(description) LIKE ? AND end_time > ? AND category = ? AND status = ?
                                OR user_id in (
                                  select id from users where key like ?
                                ) AND end_time > ? AND category = ? AND status = ?',
                                "%#{slug}%", Time.now, 'Tech', 'live',
                                "%#{slug}%", Time.now, 'Tech', 'live',
                                "%#{slug}%", Time.now, 'Tech', 'live').page(params[:page]).per_page(3)
    elsif params[:products] == 'percent_off'
      @products = Product.where('status = ? AND end_time > ? AND category = ?', 'live', Time.now, 'Tech').order(percent_discount: :desc).page(params[:page]).per_page(3)
    else
      @products = Product.where('status = ? AND category = ?', 'live', 'Tech').page(params[:page]).per_page(3)
    end
    Stripe.api_key = ENV['STRIPE_SECRET_KEY']
    if current_user.is_retailer? && current_user.retailer.stripe_id
      @stripe_customer = Stripe::Customer.retrieve(current_user.retailer.stripe_id)
    end
  end

  def accessories
    authenticate_anybody
    if params[:products] == 'discounted'
      @products = Product.where('status = ? AND end_time > ? AND current_sales >= products.goal AND category = ?', 'live', Time.now, 'Accessories').page(params[:page]).per_page(3)
    elsif params[:query]
      query = params[:query]
      slug = query.downcase
      slug.gsub!(',' '')
      slug.gsub!("'", "")
      slug.gsub!('.', '')
      slug.gsub!(' ', '-')
      @products = Product.where('slug LIKE ? AND end_time > ? AND category = ? AND status = ?
                                OR LOWER(description) LIKE ? AND end_time > ? AND category = ? AND status = ?
                                OR user_id in (
                                  select id from users where key like ?
                                ) AND end_time > ? AND category = ? AND status = ?',
                                "%#{slug}%", Time.now, 'Accessories', 'live',
                                "%#{slug}%", Time.now, 'Accessories', 'live',
                                "%#{slug}%", Time.now, 'Accessories', 'live').page(params[:page]).per_page(3)
    elsif params[:products] == 'percent_off'
      @products = Product.where('status = ? AND end_time > ? AND category = ?', 'live', Time.now, 'Accessories').order(percent_discount: :desc).page(params[:page]).per_page(3)
    else
      @products = Product.where('status = ? AND category = ?', 'live', 'Accessories').page(params[:page]).per_page(3)
    end
    Stripe.api_key = ENV['STRIPE_SECRET_KEY']
    # if current_user.is_retailer? && current_user.retailer.stripe_id
    #   @stripe_customer = Stripe::Customer.retrieve(current_user.retailer.stripe_id)
    # end
  end

  def home_goods
    authenticate_anybody
    if params[:products] == 'discounted'
      @products = Product.where('status = ? AND end_time > ? AND current_sales >= products.goal AND category = ?', 'live', Time.now, 'Home Goods').page(params[:page]).per_page(3)
    elsif params[:query]
      # binding.pry
      query = params[:query]
      slug = query.downcase
      slug.gsub!(',' '')
      slug.gsub!("'", "")
      slug.gsub!('.', '')
      slug.gsub!(' ', '-')
      @products = Product.where('slug LIKE ? AND end_time > ? AND category = ? AND status = ?
                                OR LOWER(description) LIKE ? AND end_time > ? AND category = ? AND status = ?
                                OR user_id in (
                                  select id from users where key like ?
                                ) AND end_time > ? AND category = ? AND status = ?',
                                "%#{slug}%", Time.now, 'Home Goods', 'live',
                                "%#{slug}%", Time.now, 'Home Goods', 'live',
                                "%#{slug}%", Time.now, 'Home Goods', 'live').page(params[:page]).per_page(3)
    elsif params[:products] == 'percent_off'
      @products = Product.where('status = ? AND end_time > ? AND category = ?', 'live', Time.now, 'Home Goods').order(percent_discount: :desc).page(params[:page]).per_page(3)
    else
      @products = Product.where('status = ? AND category = ?', 'live', 'Home Goods').page(params[:page]).per_page(3)
    end
    Stripe.api_key = ENV['STRIPE_SECRET_KEY']
    if current_user.is_retailer? && current_user.retailer.stripe_id
      @stripe_customer = Stripe::Customer.retrieve(current_user.retailer.stripe_id)
    end
  end

  def apparel
    authenticate_anybody
    if params[:products] == 'discounted'
      @products = Product.where('status = ? AND end_time > ? AND current_sales >= products.goal AND category = ?', 'live', Time.now, 'Apparel').page(params[:page]).per_page(3)
    elsif params[:query]
      # binding.pry
      query = params[:query]
      slug = query.downcase
      slug.gsub!(',' '')
      slug.gsub!("'", "")
      slug.gsub!('.', '')
      slug.gsub!(' ', '-')
      @products = Product.where('slug LIKE ? AND end_time > ? AND category = ? AND status = ?
                                OR LOWER(description) LIKE ? AND end_time > ? AND category = ? AND status = ?
                                OR user_id in (
                                  select id from users where key like ?
                                ) AND end_time > ? AND category = ? AND status = ?',
                                "%#{slug}%", Time.now, 'Apparel', 'live',
                                "%#{slug}%", Time.now, 'Apparel', 'live',
                                "%#{slug}%", Time.now, 'Apparel', 'live').page(params[:page]).per_page(3)
    elsif params[:products] == 'percent_off'
      @products = Product.where('status = ? AND end_time > ? AND category = ?', 'live', Time.now, 'Apparel').order(percent_discount: :desc).page(params[:page]).per_page(3)
    else
      @products = Product.where('status = ? AND category = ?', 'live', 'Apparel').page(params[:page]).per_page(3)
    end
    Stripe.api_key = ENV['STRIPE_SECRET_KEY']
    if current_user.is_retailer? && current_user.retailer.stripe_id
      @stripe_customer = Stripe::Customer.retrieve(current_user.retailer.stripe_id)
    end
  end

  def company_show
    @company = Company.find_by_company_key(params[:key])
    @products = Product.where('wholesaler_id = ? AND status = ? AND end_time >= ?', @company.user.wholesaler.id, 'live', Time.now)
    if current_user.is_retailer? && current_user.retailer.stripe_id
      @stripe_customer = Stripe::Customer.retrieve(current_user.retailer.stripe_id)
    end
  end

  def regularly_priced
    @products = Product.where('id in (
      select product_id from product_tokens where expiration_datetime > ?
    )', Time.now).page(params[:page]).per_page(3)
  end

  private
  def redirect_if_not_logged_in
    redirect_to '/users' if current_user.nil?
  end

end
