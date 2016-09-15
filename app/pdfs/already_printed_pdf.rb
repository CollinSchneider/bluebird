class AlreadyPrintedPdf < Prawn::Document

  def initialize(user)
    super()
    product_array = user.wholesaler.products.where('status = ? OR status = ? OR status = ?', 'goal_met', 'discount_granted', 'full_price').pluck(:id).to_a
    need_to_ship = Commit.where('product_id in (?) AND shipping_id IS NULL AND card_declined != ?', product_array, true)

    directions_title(user)
    directions
    bluebird_image
    start_new_page

    need_to_ship.each do |commit|
      pdf_sequence(commit)
    end

  end

  def pdf_sequence(commit)
    image_header
    product_title(commit.product)
    pad_bottom(30) {seller_info(commit.product.wholesaler.user)}
    stroke_horizontal_rule
    pad_bottom(15) {buyer_info(commit.retailer)}
    stroke_horizontal_rule
    pad_bottom(10) {column_headers}
    stroke_horizontal_rule
    pad_bottom(10) {order_info(commit)}
    stroke_horizontal_rule
    pad_bottom(10) {shipping_info}
    stroke_horizontal_rule
    order_total(commit)
    start_new_page
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

  def buyer_info(retailer)
    move_down 15
    EasyPost.api_key = ENV['EASYPOST_API_KEY']
    address = EasyPost::Address.retrieve(retailer.shipping_addresses[0].address_id)
    text "Buyer: #{retailer.user.full_name} \n
    #{retailer.company.company_name} \n
    #{address.street1.downcase.capitalize} \n
    #{address.city.downcase.capitalize}, #{address.state}, #{address.zip}"
  end

  def seller_info(user)
    text "Seller: #{user.company.company_name}", align: :center
  end

  def column_headers
    move_down 10
    text "Product             Unit Price             Quantity             Total Price", align: :right, style: :bold
  end

  def order_info(commit)
    move_down 10
    if !commit.full_price
      text "#{commit.product.title.pluralize}                   $#{commit.product.discount}                    #{commit.amount}                    $#{'%.2f' % (commit.product.discount.to_f*commit.amount.to_f)}", align: :right
    else
      text "#{commit.product.title.pluralize}                   $#{commit.product.price}                    #{commit.amount}                    $#{'%.2f' % (commit.product.price.to_f*commit.amount.to_f)}", align: :right
    end
  end

  def shipping_info
    move_down 10
    text "Shipping: (Calculated Later)", align: :right
  end

  def order_total(commit)
    move_down 10
    if !commit.full_price
      text "Total: $#{'%.2f' % (commit.amount.to_f*commit.product.discount.to_f)}", align: :right, style: :bold
    else
      text "Total: $#{'%.2f' % (commit.amount.to_f*commit.product.price.to_f)}", align: :right, style: :bold
    end
  end

end