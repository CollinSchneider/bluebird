class CommitsController < ApplicationController
  before_action :redirect_if_not_retailer
  skip_before_filter :verify_authenticity_token, :only => [:create]

  def create
    if current_user.retailer.commits.find_by(:product_id => params[:product_id])
      raise "User already has an order for this product"
    end
    product = Product.find(params[:product_id])
    total_orders = params[:quantity].values.map(&:to_f).reduce(:+)
    if !product.minimum_order.nil? && total_orders < product.minimum_order
      flash[:error] = "Order must be for at least #{product.minimum_order} units."
      return redirect_to request.referrer
    end
    @commit = product.make_commit(current_user)
    params[:quantity].each do |sku_id, quantity|
      create_purchase_order(sku_id, quantity)
    end
    redirect_to shipping_commit_path(@commit.id)
  end

  def update
    @commit = Commit.find(params[:id])
    product = Product.find(params[:product_id])
    total_orders = params[:quantity].values.map(&:to_f).reduce(:+)
    if !product.minimum_order.nil? && total_orders < product.minimum_order
      flash[:error] = "Order must be for at least #{product.minimum_order} units."
      return redirect_to request.referrer
    end
    ordered_quantity = ActiveSupport::OrderedHash[*params[:quantity].sort_by{|k,v| v.to_f}.reverse.flatten]
    ordered_quantity.each do |sku_id, quantity|
      if quantity.to_f > 0
        create_or_update_purchase_order(sku_id, quantity)
      elsif po = PurchaseOrder.find_by(:sku_id => sku_id)
        po.delete
      end
    end
    flash[:success] = "Order updated."
    redirect_to "/retailer/order_history/#{@commit.id}"
  end

  def create_purchase_order(sku_id, quantity)
    sku = Sku.find(sku_id)
    amount = sku.inventory - quantity.to_f >= 0 ? quantity.to_f : sku.inventory
    if amount > 0
      @commit.add_po(sku, amount)
    end
  end

  def create_or_update_purchase_order(sku_id, quantity)
    sku = Sku.find(sku_id)
    amount = sku.inventory - quantity.to_f >= 0 ? quantity.to_f : sku.inventory
    if po = PurchaseOrder.find_by(:commit_id => @commit.id, :sku_id => sku_id)
      po.update(
        :quantity => amount,
        :sale_amount_with_fees => amount*sku.price_with_fee,
        :sale_amount => amount*sku.discount_price
      )
    else
      create_purchase_order(sku_id, amount)
    end
  end

  def destroy
    commit = Commit.find(params[:id])
    product = Product.find(commit.product_id)
    if commit.retailer_id == current_user.retailer.id
      commit.destroy_commit
      return redirect_to "/products/#{product.id}/#{product.slug}"
    end
  end

  def shipping
    @commit = Commit.find(params[:id])
    return redirect_to '/retailer' if @commit.retailer_id != current_user.retailer.id
    @new_shipping_address = ShippingAddress.new
  end

  def set_shipping
    commit = Commit.find(params[:id])
    commit.shipping_address_id = params[:shipping_address_id]
    commit.save!
    flash[:success] = "Address saved."
    if params[:edit] == 'true'
      return redirect_to "/retailer/order_history/#{commit.id}"
    else
      return redirect_to payment_commit_path(commit.id)
    end
  end

  def payment
    @commit = Commit.find(params[:id])
    return redirect_to '/retailer' if @commit.retailer_id != current_user.retailer.id
    return redirect_to shipping_commit_path(@commit.id) if @commit.shipping_address_id.nil?
    Stripe.api_key = ENV['STRIPE_SECRET_KEY']
    @stripe_customer = Stripe::Customer.retrieve(current_user.retailer.stripe_id)
  end

  def set_payment
    commit = Commit.find(params[:id])
    commit.card_id = params[:card_id]
    if params[:edit] == 'true'
      return_path = "/retailer/order_history/#{commit.id}"
    else
      commit.status = 'live'
      return_path = receipt_commit_path(commit.id)
    end
    flash[:success] = "Payment saved."
    commit.save!
    return redirect_to return_path
  end

  def receipt
    @commit = Commit.find(params[:id])
    Stripe.api_key = ENV['STRIPE_SECRET_KEY']
    stripe_customer = Stripe::Customer.retrieve(current_user.retailer.stripe_id)
    @card = stripe_customer.sources.retrieve(@commit.card_id)
  end

  private
  def commit_params
    params.require(:commit).permit(:user_id, :product_id, :amount, :status, :uuid, :full_price, :retailer_id)
  end

  def redirect_if_not_retailer
    redirect_to "/users" if current_user.nil?
    redirect_to "/wholesaler" if current_user.is_wholesaler?
  end

end
