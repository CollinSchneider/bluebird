require 'easypost'
class Api::ShippingController < ApiController

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
        if charge[0]
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
