require 'stripe'
class WelcomeController < ApplicationController

  def shop
    authenticate_anybody
    if params[:products] == 'fulfilled'
      # TODO: Come back to this, not sure when product becomes 'goal_met'
      @products = Product.where('status = ? AND end_time > ?', 'goal_met', Time.now)
    elsif params[:query]
      # binding.pry
      query = params[:query]
      slug = query.downcase
      slug.gsub!(',' '')
      slug.gsub!("'", "")
      slug.gsub!('.', '')
      slug.gsub!(' ', '-')
      @products = Product.where('slug LIKE ?', "%#{slug}%")
      # @products = Product.find_by_slug(slug)
      binding.pry
    else
      @products = Product.where('status = ?', 'live')
    end
    Stripe.api_key = ENV["STRIPE_SECRET_KEY"]
    # if current_user.retailer_stripe_id
    #   @stripe_customer = Stripe::Customer.retrieve(current_user.retailer_stripe_id)
    # end
  end

  def landing
  end

  def about
  end

  def faq
  end

end
