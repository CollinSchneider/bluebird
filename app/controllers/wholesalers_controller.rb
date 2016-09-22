require 'easypost'
class WholesalersController < ApplicationController
  layout 'wholesaler'
  before_action :authenticate_wholesaler

  def profile
    @commits_where_card_declined = current_user.wholesaler.products.where('
                                              products.status = ? OR products.status = ? OR products.status = ?',
                                              'goal_met', 'discount_granted', 'full_price').joins(:commits).where('
                                                shipping_id IS NULL AND card_declined = ?
                                              ', true).count
    # @needs_attention = current_user.wholesaler.products.where('status = ?', 'needs_attention')
    # @needs_shipping = current_user.wholesaler.products.where('
    #                                           products.status = ? OR products.status = ? OR products.status = ?',
    #                                           'goal_met', 'discount_granted', 'full_price').joins(:commits).where('
    #                                             shipping_id IS NULL AND card_declined != ?
    #                                           ', true)
    # @receipts_to_generate = @needs_shipping.where('pdf_generated != ?', false)
  end

  def new_product
    redirect_to '/wholesaler/profile' if current_user.wholesaler.needs_to_ship? || current_user.wholesaler.needs_attention? || current_user.wholesaler.needs_stripe_connect?
    @product = Product.new
  end

  def approve_product
    @product = Product.find(params[:id])
    redirect_to "/wholesaler/profile" if @product.wholesaler_id != current_user.wholesaler.id
  end

  def fix_product
    @product = Product.find(params[:product])
    redirect_to "/wholesaler/profile" if @product.wholesaler_id != current_user.wholesaler.id
  end

  def launch_product
    if request.put?
      @product = Product.find(params[:id])
      @product.set_product_start_data
      return redirect_to "/products/#{@product.id}-#{@product.slug}"
    end
  end

  def start_over
    product = Product.find_by(:uuid => params[:uuid])
    product.destroy
    return redirect_to "/new_product?duration=#{params[:duration]}&goal=#{params[:goal]}"
  end

  def relist
    @product = Product.find_by_uuid(params[:uuid])
  end

  def current_sales
    if params[:query]
      query = "%#{params[:query].gsub(' ', '').downcase}%"
      @products = current_user.wholesaler.products.where('status = ? AND lower(title) LIKE ? or status = ?
        AND lower(description) LIKE ?', 'live', query, 'live', query
        ).order(end_time: :asc).page(params[:page]).per_page(6)
    else
      @products = current_user.wholesaler.products.where('status = ?', 'live'
        ).order(end_time: :asc).page(params[:page]).per_page(6)
    end
  end

  def past_products
    if params[:query]
      query = "%#{params[:query].gsub(' ', '').downcase}%"
      @products = current_user.wholesaler.products.where('status != ? AND status != ? AND lower(title) LIKE ? OR status != ? AND status != ? AND lower(description) LIKE ?',
        'live', 'needs_attention', query, 'live', 'needs_attention', query).order(end_time: :asc).page(params[:page]).per_page(6)
    else
      @products = current_user.wholesaler.products.where('status != ? AND status != ?', 'live', 'needs_attention').order(end_time: :desc).page(params[:page]).per_page(6)
    end
  end

  def analytics
    @sale_commits = Commit.where('product_id in (
      select id from products where wholesaler_id = ?
    ) AND product_id in (
      select id from products where status = ? OR status = ?
    )', current_user.wholesaler.id, 'goal_met', 'discount_granted')
    goal_met_products = current_user.wholesaler.products.where('status = ? OR status = ?', 'goal_met', 'discount_granted')
    product_ids = goal_met_products.pluck(:id)
    # @total_commits = Commit.where('product_id in (?)', product_ids).sum(:amount)
    @total_commits = Commit.where('product_id in (
      select id from products where wholesaler_id = ?
    )', current_user.wholesaler.id)
    @total_sales = 0
    goal_met_products.each do |product|
      @total_sales += product.total_sales
    end
    @top_sellers = goal_met_products.order(current_sales: :desc).limit(5)
  end

  def needs_attention
    @products = current_user.wholesaler.products.where('status = ?', 'needs_attention')
  end

  def manage_shipping
    EasyPost.api_key = "sl7EFdaoEC2GaVf5qYjz0g"
    @users_addresses = []
    current_user.shipping_addresses.each do |address|
      easy_post_address = EasyPost::Address.retrieve(address.address_id)
      @users_addresses.push(easy_post_address)
    end
  end

  def accounts
    Stripe.api_key = "sk_test_TI9EamOjFwLiHOvvNF6Q1cIn"
    if current_user.stripe_credential.present?
      @stripe_customer = Stripe::Account.retrieve(current_user.stripe_credential.stripe_user_id)
    end
  end

  def company
    @wholesaler = current_user.wholesaler
    @company = current_user.company
    if request.put?
      #
    end
  end

  def needs_shipping
    product_array = current_user.wholesaler.products.where('status = ? OR status = ? OR status = ?', 'goal_met', 'discount_granted', 'full_price').pluck(:id).to_a
    @need_to_ship = Commit.where('product_id in (?) AND shipping_id IS NULL AND card_declined != ?', product_array, true)

    @receipts_to_generate = @need_to_ship.where('pdf_generated != ?', false)

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

  def already_printed
    respond_to do |format|
      format.pdf do
        pdf = AlreadyPrintedPdf.new(current_user)
        send_data pdf.render,
            filename: "#{Time.now.strftime('%B/%d/%Y')}-Order.pdf",
            type: 'application/pdf'
      end
    end
  end

  def change_password
    if request.put?
      if params[:user][:password] == params[:user][:confirm_password]
        if params[:user][:password].length > 7
          current_user.update(user_password_params)
          flash[:success] = "Password Updated"
        else
          flash[:error] = "Password must be at least 8 characters long."
        end
      else
        flash[:error] = "Password and Password Confirmation must match."
      end
      return redirect_to request.referrer
    end
  end

  private
  def user_password_params
    params.require(:user).permit(:password)
  end

  def product_params
    params.require(:product).permit(:user_id, :percent_discont, :goal, :company_name, :current_sales,
      :duration, :title, :price, :description, :discount, :status, :category, :quantity, :minimum_order,
      :main_image, :photo_two, :photo_three, :photo_four, :photo_five)
  end

  def authenticate_wholesaler
    redirect_to '/users' if current_user.nil?
    redirect_to '/shop' if current_user.is_retailer?
  end

end
