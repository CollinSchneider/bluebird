class OrderPdf < Prawn::Document

  def initialize(user)
    super()
    products_to_ship = user.products.where('
          products.status = ? OR products.status = ?', 'goal_met', 'discount_granted'
        ).joins(:commits).where('
          shipping_id IS NULL
        ')
    text "Will eventually be directions..."
    start_new_page
    products_to_ship.each do |product|
      product.commits.each do |commit|
        pad_bottom(30) {product_title(product)}
        stroke_horizontal_rule
        pad_bottom(15) {buyer_info(commit.user)}
        stroke_horizontal_rule
        pad_bottom(15) {seller_info(commit.product.user)}
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

  def product_title(product)
    text "#{product.title} Shipments", size: 30, style: :bold, align: :center
  end

  def buyer_info(user)
    move_down 15
    EasyPost.api_key = "sl7EFdaoEC2GaVf5qYjz0g"
    address = EasyPost::Address.retrieve(user.shipping_addresses[0].address_id)
    text "Buyer: #{user.email} \n
    #{address.company} \n
    #{address.street1} \n
    #{address.city}, #{address.state}, #{address.zip} \n
    #{address.phone}"
  end

  def seller_info(user)
    move_down 15
    EasyPost.api_key = "sl7EFdaoEC2GaVf5qYjz0g"
    address = EasyPost::Address.retrieve(user.shipping_addresses[0].address_id)
    text "Seller: #{user.email} \n
    #{address.company} \n
    #{address.street1} \n
    #{address.city}, #{address.state}, #{address.zip} \n
    #{address.phone}"
  end

  def order_info(commit)
    move_down 10
    text "Orders: #{commit.amount} #{commit.product.title.pluralize} x $#{'%.2f' % (commit.product.discount)}", align: :right
  end

  def shipping_info
    move_down 10
    text "Shipping: (Calculated Later)", align: :right
  end

  def order_total(commit)
    move_down 10
    text "Total: $#{'%.2f' % (commit.amount.to_f*commit.product.discount.to_f)}", align: :right
  end

end
