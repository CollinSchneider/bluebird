require 'easypost'
class Api::ShippingController < ApiController

  def create_shipping_address
    street_one = params[:street_line_1]
    street_two = params[:street_line_2]
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
      render :json => {
        success: true,
        address: verifiable_address
      }
      current_user.retailer.shipping_addresses.each do |address|
        address.primary = false
        address.save
      end
      local_address = ShippingAddress.new
      local_address.retailer_id = current_user.retailer.id
      local_address.address_id = verifiable_address.id
      local_address.primary = true
      local_address.save
    else
      render :json => {
        success: false,
        errors: verifiable_address.verifications.delivery.errors
      }
    end
  end

  def ship_order
    commit = Commit.find(params[:commit_id])
    tracking_code = params[:tracking_code]
    EasyPost.api_key = ENV['EASYPOST_API_KEY']
    begin
      tracker = EasyPost::Tracker.create({
        tracking_code: tracking_code
      })
      if !tracker.nil?
        shipping_cost = 0
        tracker.fees.each do |fee|
          shipping_cost += fee.amount.to_f
        end
        charge = current_user.collect_shipping_charge(commit, shipping_cost)
        if charge[0] == true
          commit.shipping_id = tracker.id
          commit.save!
          render :json => {
            success: true,
            charge: charge[1],
            tracking: tracker
          }
        else
          # commit.card_declined = true
          # commit.card_decline_date = Time.now
          # commit.save!
          render :json => {
            success: false,
            error: charge[1]
          }
        end
      end
    rescue EasyPost::Error => e
      render :json => {
        success: false,
        error: e.message
      }
    end
  end

end
