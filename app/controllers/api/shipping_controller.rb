require 'easypost'
class Api::ShippingController < ApiController

  def create_shipping_address
    street_one = params[:street_one]
    street_two = params[:street_two]
    city = params[:city]
    state = params[:state]
    zip = params[:zip]
    EasyPost.api_key = ENV["EASYPOST_API_KEY"]
    verifiable_address = EasyPost::Address.create(
      verify: ["delivery"],
      street1: street_one,
      street2: street_two,
      city: city,
      state: state,
      zip: zip,
      country: "US"
    )
    if verifiable_address.verifications.delivery.success
      current_user.retailer.shipping_addresses.each do |address|
        address.primary = false
        address.save
      end
      local_address = ShippingAddress.new
      local_address.retailer_id = current_user.retailer.id
      local_address.address_id = verifiable_address.id
      local_address.primary = true
      local_address.street_address_one = verifiable_address.street1
      local_address.street_address_two = verifiable_address.street2
      local_address.city = verifiable_address.city
      local_address.zip =  verifiable_address.zip
      local_address.state = verifiable_address.state
      local_address.save
      # return redirect_to request.referrer
      return render :json => {
        success: true,
        easy_address: verifiable_address,
        local_address: local_address
      }
    else
      flash[:error] = verifiable_address.verifications.delivery.errors
      # return redirect_to request.referrer
      return render :json => {
        success: false,
        errors: verifiable_address.verifications.delivery.errors
      }
    end
  end

  def create_initial_shipment
    tracking_code = params[:tracking_code].gsub(' ', '')
    shipping_cost = params[:shipping_amount]
    if shipping_cost.to_f < 0.5 && shipping_cost.to_f > 0
      return render :json => {
        success: false,
        error: "If you are charging for shipping, you must charge at least $0.50."
      }
    end
    tracking_code = tracking_code.gsub('-', '')
    tracking_code = tracking_code.gsub('.', '')
    EasyPost.api_key = ENV['EASYPOST_API_KEY']
    begin
      tracker = EasyPost::Tracker.create({
        tracking_code: tracking_code
      })
      if !tracker.nil?
        # charge = current_user.collect_shipping_charge(commit, shipping_cost)
        shipment = Shipping.new
        shipment.tracking_id = tracker.id
        shipment.shipping_amount = shipping_cost
        shipment.wholesaler = current_user.wholesaler
        shipment.save!
        return render :json => {
          success: true,
          tracking: tracker,
          shipment: shipment
        }
      end
    rescue EasyPost::Error => e
      return render :json => {
        success: false,
        error: e.message
      }
    end
  end

  def complete_shipment
    orders = JSON.parse(params[:orders])
    order_check = orders.first['addressId']
    orders.each do |order_address_check|
      if order_address_check['addressId'] != order_check
        return render :json => {
          success: false,
          message: "Each order has to be shipped to the same address, please update the shipment's orders."
        }
      end
    end
    shipment = Shipping.find(params[:shipment])
    purchase_order = PurchaseOrder.find(orders.first['poId'])
    order_complete = false
    orders.each do |order|
      po = PurchaseOrder.find(order['poId'])
      po.has_shipped = true
      po.shipping_id = shipment.id
      po.save!
      order_complete = po.commit.purchase_orders.where(:has_shipped => true).count == po.commit.purchase_orders.count ? true : false
    end
    if purchase_order.commit.shipping_amount.nil?
      purchase_order.commit.shipping_amount = 0
    end
    if order_complete
      purchase_order.commit.has_shipped = order_complete
      rating = Rating.new
      rating.sale_id = purchase_order.commit.sale.id
      rating.save!
    end
    purchase_order.commit.shipping_amount += shipment.shipping_amount
    purchase_order.commit.save!
    shipment.shipped_on = Time.current
    shipment.retailer_id = purchase_order.commit.retailer_id
    shipment.save!
    EasyPost.api_key = ENV['EASYPOST_API_KEY']
    tracker = EasyPost::Tracker.retrieve(shipment.tracking_id)
    if shipment.shipping_amount == 0
      BlueBirdEmail.retailer_sale_shipped(shipment.retailer.user, shipment, tracker.carrier, tracker.tracking_code, tracker.est_delivery_date, tracker.public_url)
      return render :json => {success: true}
    else
      charge = current_user.collect_shipping_charge(shipment)
      if charge[0] == true
        BlueBirdEmail.retailer_sale_shipped(shipment.retailer.user, shipment, tracker.carrier, tracker.tracking_code, tracker.est_delivery_date, tracker.public_url)
      else
        BlueBirdEmail.retailer_declined_card_sale_shipped(shipment.retailer.user, shipment, tracker.carrier, tracker.tracking_code, tracker.est_delivery_date, tracker.public_url)
      end
      return render :json => {
        success: true,
        charge: charge[1]
      }
    end
  end

  def delete_address
    address = ShippingAddress.find(params[:id])
    address_commits = current_user.retailer.commits.where("shipping_address_id = ? and (status = ? or id not in (
      select commit_id from purchase_orders where sale_made = 't' and has_shipped = 'f'
    ))", address.id, 'live')
    messages = []
    address_commits.each do |commit|
      messages << "<a href='/retailer/order_history/#{commit.id}'>#{commit.product.title}</a>".html_safe
    end
    if address_commits.any?
      return render :json => {
        success: false,
        addresses: address_commits,
        html: messages
      }
    else
      address.delete
      render :json => {success: true}
    end
  end

  def make_primary_address
    address = ShippingAddress.find(params[:address_id])
    primary_address = current_user.retailer.shipping_addresses.where(:primary => true).first
    primary_address.primary = false
    primary_address.save
    address.primary = true
    address.save
    render :json => {success: true}
  end

  def change_commit_shipping
    shipping_id = params[:shipping_id]
    commit_id = params[:commit_id]
    commit = Commit.find(commit_id)
    commit.shipping_address_id = shipping_id
    if commit.save!
      return render :json => {:success => true}
    else
      return render :json => {:success => false}
    end
  end

end
