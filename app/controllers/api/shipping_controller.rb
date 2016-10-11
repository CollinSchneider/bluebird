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

  def ship_order
    commit = Commit.find_by_uuid(params[:commit_uuid])
    tracking_code = params[:tracking_code].gsub(' ', '')
    shipping_cost = params[:shipping_amount]
    tracking_code = tracking_code.gsub('-', '')
    tracking_code = tracking_code.gsub('.', '')
    EasyPost.api_key = ENV['EASYPOST_API_KEY']
    begin
      tracker = EasyPost::Tracker.create({
        tracking_code: tracking_code
      })
      if !tracker.nil?
        charge = current_user.collect_shipping_charge(commit, shipping_cost)
        shipment = Shipping.where('commit_id = ?', commit.id).first
        shipment.tracking_id = tracker.id
        shipment.shipped_on = DateTime.now
        shipment.save!
        commit.has_shipped = true
        commit.save(validate: false)
        if charge[0] == true
          BlueBirdEmail.retailer_sale_shipped(commit.retailer.user, tracker.carrier, tracker.tracking_code, tracker.est_delivery_date, tracker.public_url)
          return render :json => {
            success: true,
            charge: charge[1],
            tracking: tracker
          }
        else
          BlueBirdEmail.retailer_declined_card_sale_shipped(commit.retailer.user, tracker.carrier, tracker.tracking_code, tracker.est_delivery_date, tracker.public_url, shipping_cost)
          return render :json => {
            success: false,
            error: charge[1]
          }
        end
      end
    rescue EasyPost::Error => e
      return render :json => {
        success: false,
        error: e.message
      }
    end
  end

  def create_initial_shipment
    tracking_code = params[:tracking_code].gsub(' ', '')
    shipping_cost = params[:shipping_amount]
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
    addresses = params[:addresses].split(',')
    if addresses.uniq.count > 1
      return render :json => {
        success: false,
        message: "Each order has to be shipped to the same address, please update the shipment's orders."
      }
    end
    retailer_id = ShippingAddress.find(addresses.first).retailer_id
    orders = params[:orders].split(',')
    shipment = Shipping.find(params[:shipment])
    orders.each do |uuid|
      order = Commit.find_by(:uuid => uuid)
      order.has_shipped = true
      order.shipping_id = shipment.id
      order.save!
    end
    shipment.shipped_on = DateTime.now
    shipment.retailer_id = retailer_id
    shipment.save!
    charge = current_user.collect_shipping_charge(shipment)
    return render :json => {success: true}
  end

  def delete_address
    address = ShippingAddress.find(params[:id])
    address_commits = current_user.retailer.commits.where('shipping_address_id = ?', address.id)
    if address_commits.any?
      return render :json => {
        success: false,
        addresses: address_commits
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
