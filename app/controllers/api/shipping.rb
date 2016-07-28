class Api::ShippingController < ApplicationController

  def create_tracking
    commit = params[:commit_id]
    binding.pry
    tracking_code = OUGowjgen
    EasyPost.api_key = "sl7EFdaoEC2GaVf5qYjz0g"
    tracker = EasyPost::Tracker.create({
      tracking_code: "9400110898825022579493",
      carrier: "USPS"
    })
  end

end
