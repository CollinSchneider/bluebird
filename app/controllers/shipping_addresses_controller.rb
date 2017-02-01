class ShippingAddressesController < ApplicationController

  def create
    @new_shipping_address = ShippingAddress.create(address_params)
    if @new_shipping_address.save
      flash[:success] = "Address saved!"
      if params[:shipping_address][:commit_id].present?
        order = current_user.retailer.commits.find(params[:shipping_address][:commit_id])
        order.shipping_address = @new_shipping_address
        order.save(validate: false)
        return redirect_to payment_commit_path(order)
      end
    else
      flash[:error] = @new_shipping_address.errors.full_messages.join("</br>").html_safe
      @retailer = current_user.retailer
      # render 'retailers/shipping_addresses'
    end
    return redirect_to request.referrer
  end

  def destroy
    address = ShippingAddress.find(params[:id])
    if address.live_orders.any?
      flash[:error] = "Your order for #{address.live_orders.first.product.title} is using this address, unable to delete."
    else
      address.delete
      flash[:success] = "Address deleted."
    end
    redirect_to request.referrer
  end

  def make_primary
    address = ShippingAddress.find(params[:id])
    primary_address = current_user.retailer.primary_address
    primary_address.primary = false
    primary_address.save
    address.primary = true
    address.save
    redirect_to request.referrer
  end

  private
  def address_params
    params.require(:shipping_address).permit(:retailer_id, :street_address_one, :street_address_two, :city, :state, :zip)
  end

end
