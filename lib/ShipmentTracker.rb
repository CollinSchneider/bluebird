class ShipmentTracker

  def initialize(args)
    raise "Missing arguments, expected 5, received #{args.count}" if args.count != 5
    @tracking_number = args[:tracking_number]
    @shipping_cost = args[:shipping_cost]
    @wholesaler = args[:wholesaler]
    @retailer_id = args[:retailer]
    @purchase_order_ids = args[:purchase_orders]
  end

  def create_tracker
    EasyPost.api_key = ENV['EASYPOST_API_KEY']
    begin
      ep_tracker = EasyPost::Tracker.create({
        tracking_code: @tracking_number
      })
      if !ep_tracker.nil?
        return save_shipment(ep_tracker)
      end
    rescue EasyPost::Error => e
      raise ShipmentTrackerError.new(e.message)
    end
  end

  private
  def save_shipment(tracker)
    shipment = Shipping.create(
      tracking_id: tracker.id,
      shipping_amount: @shipping_cost,
      wholesaler_id: @wholesaler.id,
      carrier: tracker.carrier,
      tracking_number: tracker.tracking_code,
      easypost_tracking_url: tracker.public_url,
      shipped_on: Time.now,
      retailer_id: @retailer_id
    )
    @purchase_order_ids.each do |po_id|
      po = PurchaseOrder.find(po_id)
      po.update(:shipping_id => shipment.id, :has_shipped => true)
    end
    first_po = PurchaseOrder.find(@purchase_order_ids.first)
    commit = first_po.commit
    commit.shipping_amount = commit.shipping_amount.nil? ? @shipping_cost : commit.shipping_amount + @shipping_cost.to_f
    commit.save!
    charge_for_shipping(shipment, tracker)
    update_statistics(first_po)
  end

  def charge_for_shipping(shipment, tracker)
    if shipment.shipping_amount == 0
      # FREE SHIPPING
      BlueBirdEmail.retailer_sale_shipped(shipment.retailer.user, shipment, shipment.carrier, shipment.tracking_number, tracker.est_delivery_date, shipment.easypost_tracking_url)
    else
      charge = @wholesaler.user.collect_shipping_charge(shipment)
      # CHECK IF CHARGE WAS SUCCESSFULL
      if charge[0] == true
        BlueBirdEmail.retailer_sale_shipped(shipment.retailer.user, shipment, shipment.carrier, shipment.tracking_number, tracker.est_delivery_date, shipment.easypost_tracking_url)
      else
        BlueBirdEmail.retailer_declined_card_sale_shipped(shipment.retailer.user, shipment, shipment.carrier, shipment.tracking_number, tracker.est_delivery_date, shipment.easypost_tracking_url)
      end
    end
    return true
  end

  def update_statistics(purchase_order)
    wholesaler = purchase_order.commit.wholesaler
    time_diff = Time.current.to_i - purchase_order.commit.product.end_time.to_i
    if wholesaler.wholesaler_stat.nil?
      stat = WholesalerStat.new
      stat.save!
      wholesaler.wholesaler_stat_id = stat.id
      wholesaler.save!
    end
    stat = wholesaler.wholesaler_stat
    stat.total_shipping_difference += time_diff
    stat.total_shipments += 1
    stat.save!
    wholesaler.save!
  end

end

class ShipmentTrackerError < StandardError

end
