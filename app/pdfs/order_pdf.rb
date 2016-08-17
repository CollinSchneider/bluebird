class OrderPdf < Prawn::Document

  def initialize(user)
    super()
    products_to_ship = user.products.where('
          products.status = ? OR products.status = ?', 'goal_met', 'discount_granted'
        ).joins(:commits).where('
          shipping_id IS NULL AND pdf_generated IS NULL')

    directions_title
    directions
    start_new_page
    products_to_ship.each do |product|
      product.commits.each do |commit|
        commit.pdf_generated = true
        commit.save

        product_title(product)
        pad_bottom(30) {seller_info(product.user)}
        stroke_horizontal_rule
        pad_bottom(15) {buyer_info(commit.user)}
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
    end
  end

  def directions_title
    text "Congrats on your completed sales! \n
    There are a few steps you must now take to get paid", align: :center, style: :bold, size: 15
  end

  def directions
    text "1.) Print off each of the receipts below", align: :center
    text "2.) Place each receipt in the according shipment", align: :center
    text "3.) Ship each order to your buyers", align: :center
    text "4.) Enter the tracking number for each order at http://BlueBird.club/needs_shipping (found in your profile)", align: :center
    text "That's it! The funds get transferred to your account upon entering the tracking number!", align: :center
  end

  def product_title(product)
    text "#{product.title} Shipment", size: 25, style: :bold, align: :center
  end

  def buyer_info(user)
    move_down 15
    EasyPost.api_key = ENV['EASYPOST_API_KEY']
    address = EasyPost::Address.retrieve(user.shipping_addresses[0].address_id)
    text "Buyer: #{user.full_name} \n
    #{address.company} \n
    #{address.street1} \n
    #{address.city}, #{address.state}, #{address.zip} \n
    #{address.phone}"
  end

  def seller_info(user)
    text "Seller: #{user.company_name}", align: :center
  end

  def column_headers
    move_down 10
    text "Product             Unit Price             Quantity             Total Price", align: :right, style: :bold
  end

  def order_info(commit)
    move_down 10
    text "#{commit.product.title.pluralize}                   $#{commit.product.discount}                    #{commit.amount}                    $#{'%.2f' % (commit.product.discount.to_f*commit.amount.to_f)}", align: :right
  end

  def shipping_info
    move_down 10
    text "Shipping: (Calculated Later)", align: :right
  end

  def order_total(commit)
    move_down 10
    text "Total: $#{'%.2f' % (commit.amount.to_f*commit.product.discount.to_f)}", align: :right, style: :bold
  end

end
