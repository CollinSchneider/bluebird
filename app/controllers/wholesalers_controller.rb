require 'easypost'
class WholesalersController < ApplicationController

  def signup
  end

  def index
    authenticate_wholesaler
    Stripe.api_key = ENV["STRIPE_SECRET_KEY"]
    @currently_selling = current_user.products.where('status = ?', 'live')
    @needs_attention = current_user.products.where('status = ?', 'needs_attention')
    @needs_shipping = current_user.products.where('
                                              products.status = ? OR products.status = ?',
                                              'goal_met', 'discount_granted').joins(:commits).where('
                                                shipping_id IS NULL
                                              ')
  end

  def new_product
    @product = Product.new
  end

  def past_products
    @products = current_user.products.where('status != ? AND status != ?', 'live', 'needs_attention')
  end

  def analytics
  end

  def needs_attention
    @products = current_user.products.where('status = ?', 'needs_attention')
  end

  def manage_shipping
    EasyPost.api_key = "sl7EFdaoEC2GaVf5qYjz0g"
    @users_addresses = []
    current_user.shipping_addresses.each do |address|
      easy_post_address = EasyPost::Address.retrieve(address.address_id)
      @users_addresses.push(easy_post_address)
    end
  end

  def ship_batch
    @batch = Batch.find(params[:id])
  end

  def accounts
    Stripe.api_key = ENV["STRIPE_SECRET_KEY"]
    @stripe_customer = Stripe::Account.retrieve(current_user.wholesaler_stripe_id)
  end

  def needs_shipping
    @needs_shipping = current_user.products.where('
                                              products.status = ? OR products.status = ?',
                                              'goal_met', 'discount_granted').joins(:commits).where('
                                                shipping_id IS NULL
                                              ')
    respond_to do |format|
      format.html
      format.pdf do
        pdf = OrderPdf.new(current_user)
        send_data pdf.render,
            filename: "#{Time.now.strftime('%B/%d/%Y')}-Order.pdf",
            type: 'application/pdf'

      end
    end
  end

  def show_needs_shipping
    @product = Product.find(params[:product_id])
  end
end
