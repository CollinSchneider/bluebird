require 'ShipmentTracker'
class ShippingsController < ApplicationController

  def create
    validate_same_address(params)
    validate_shipping_cost(params)
    tracking_number = params[:shipping][:tracking_number]
    shipping_cost = params[:shipping][:shipping_amount]
    shipping_address = ShippingAddress.find(params[:po_address].first[1])
    tracker = ShipmentTracker.new(
      tracking_number: tracking_number,
      shipping_cost: shipping_cost,
      wholesaler: current_user.wholesaler,
      retailer: shipping_address.retailer_id,
      purchase_orders: params[:po].values
    )
    begin tracker.create_tracker
      flash[:success] = "Shipped!"
    rescue ShipmentTrackerError => e
      flash[:error] = e.message
    end
    redirect_to '/needs_shipping'
  end

  private
  def validate_same_address(params)
    add_id = params[:po_address].first[1]
    params[:po_address].each do |add|
      return flash[:error] = "Each order in a shipment must be to going to the same address" if add_id != add[1]
    end
  end

  def validate_shipping_cost(params)
    shipping_cost = params[:shipping][:shipping_amount].to_f
    if shipping_cost < 0.5 && shipping_cost > 0
      return flash[:error] = "If you are charging for shipping, you must charge at least $0.50."
    end
  end

end
