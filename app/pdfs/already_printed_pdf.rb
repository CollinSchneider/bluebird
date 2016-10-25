require "open-uri"
class AlreadyPrintedPdf < Prawn::Document

  def initialize(user)
    super()
    directions_title(user)
    directions
    bluebird_image
    start_new_page

    addresses = ShippingAddress.where("id in (
      select shipping_address_id from commits where wholesaler_id = ? AND id in (
        select commit_id from purchase_orders where (purchase_orders.sale_made = 't' or purchase_orders.full_price = 't') AND purchase_orders.has_shipped = 'f' AND purchase_orders.refunded = 'f' and commit_id not in (
          select id from sales where card_failed = 't'
        )
      )
    )", user.wholesaler.id)

    total_addresses = 0
    addresses.each do |address|
      total_addresses += 1
      pdf_seller_info(user)
      pdf_buyer_sequence(address)
      start_new_page if total_addresses != addresses.length
    end
  end

  def pdf_seller_info(user)
    image_header
    move_down 15
    text "Seller: #{user.company.company_name}"
    stroke_horizontal_rule
  end

  def pdf_buyer_sequence(address)
    buyer_info(address)
    stroke_horizontal_rule
    pad_bottom(10) {column_headers}
    order_total = 0
    address.orders_to_ship.each do |po|
      amount = po.full_price? ? po.quantity*po.sku.price : po.quantity*po.sku.price_with_fee
      order_total += amount
      pad_bottom(10) {order_info(po)}
      stroke_horizontal_rule
    end
    pad_bottom(10) {shipping_info}
    stroke_horizontal_rule
    order_total(order_total)
  end

  def pdf_sequence(commit)
    image_header
    product_title(commit.product)
    move_down 15
    pad_bottom(30) {seller_info(commit.product.wholesaler.user)}
    stroke_horizontal_rule
    pad_bottom(15) {buyer_info(commit)}
    stroke_horizontal_rule
    pad_bottom(10) {column_headers}
    stroke_horizontal_rule
    pad_bottom(10) {order_info(commit)}
    stroke_horizontal_rule
    pad_bottom(10) {shipping_info}
    stroke_horizontal_rule
    order_total(commit)
  end

  def directions_title(user)
    text "Congrats on your sales, #{user.first_name}! \n
    There are a few steps you must now take to get paid.", align: :center, style: :bold, size: 15
  end

  def directions
    move_down 10
    text "These are all the receipts for products in which you have not entered shipping information yet. \n
    After following these steps, these receipts will no longer be located here. \n
    1.) Print off each of the receipts below \n
    2.) Place each receipt in the according shipment \n
    3.) Ship each order to your buyers \n
    4.) Enter the tracking number for each order at http://BlueBird.club/needs_shipping (found in your profile) \n \n
    That's it! The funds get transferred to your account upon entering the tracking number!", align: :center
  end

  def bluebird_image
    move_down 20
    image "#{Rails.root}/public/images/bluebird-blue-mascot.png", :position => :center, :width => 75
  end

  def image_header
     image "#{Rails.root}/public/images/bluebird-blue-text.png", :position => :center, :width => 300
  end

  def product_title(product)
    move_down 20
    text "#{product.title} Shipment", size: 25, style: :bold, align: :center
  end

  def buyer_info(address)
    move_down 15
    text "Buyer: #{address.retailer.user.full_name} \n
    #{address.retailer.company.company_name} \n
    #{address.street_address_one.downcase.capitalize} \n
    #{address.city.downcase.capitalize}, #{address.state}, #{address.zip}"
  end

  def seller_info(user)
    text "Seller: #{user.company.company_name}", align: :center
  end

  def column_headers
    move_down 10
    text "Product             Unit Price             Quantity             Total Price", align: :right, style: :bold
  end

  def order_info(purchase_order)
    move_down 10
    "#{image open(purchase_order.sku.image.url(:medium)), :position => :left, width: 75}" if !purchase_order.sku.image.content_type.include?('gif')
    if !purchase_order.commit.full_price
      text "#{purchase_order.sku.description}                  $#{'%.2f' % (purchase_order.sku.price_with_fee)}                    #{purchase_order.quantity}                    $#{'%.2f' % (purchase_order.sku.price_with_fee*purchase_order.quantity)}", align: :right
    else
      text "#{purchase_order.sku.description}                  $#{'%.2f' % (purchase_order.sku.price)}                    #{purchase_order.quantity}                    $#{'%.2f' % (purchase_order.sku.price*purchase_order.quantity)}", align: :right
    end
  end

  def shipping_info
    move_down 10
    text "Shipping: (Calculated Later)", align: :right
  end

  def order_total(order_total)
    move_down 10
    text "Total: $#{'%.2f' % order_total}", align: :right, style: :bold
    # if !commit.full_price
    #   text "Total: $#{'%.2f' % (commit.amount.to_f*commit.product.discount.to_f)}", align: :right, style: :bold
    # else
    #   text "Total: $#{'%.2f' % (commit.amount.to_f*commit.product.price.to_f)}", align: :right, style: :bold
    # end
  end

end
