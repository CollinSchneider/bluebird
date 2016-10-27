class Api::OrdersController < ApiController

  def make_purchase_order
    orders = JSON.parse(params[:orders])
    product = Product.find(params[:product])

    total_orders = 0
    orders.each do |obj|
      total_orders += obj['quantity'].to_i
    end
    if total_orders < product.minimum_order
      return render :json => {
        success: false,
        message: "Cannot update order, total quantity must be at least #{product.minimum_order}"
      }
    end

    find_commit = Commit.find_by(:product_id => product.id, :retailer_id => current_user.retailer.id)
    if find_commit.nil?
      message = create_new_commit(orders, product)
    else
      message = update_commit(find_commit, orders)
    end
    return render :json => {
      success: true,
      message: message
    }
  end

  def update_commit(commit, orders)
    total_difference = 0
    message = nil
    orders.each do |order|
      find_po = commit.purchase_orders.where('sku_id = ?', order['sku'])
      sku = Sku.find(order['sku'])
      if find_po.empty? && order['quantity'].to_i != 0
        # create a new purchase order for commit
        actual_quantity = new_purchase_order(order['quantity'], sku, commit, false)

        commit.amount += actual_quantity
        commit.sale_amount += actual_quantity*sku.discount_price
        commit.sale_amount_with_fees += actual_quantity*sku.price_with_fee
        commit.save!
        commit.product.current_sales += actual_quantity*sku.discount_price
        commit.product.current_sales_with_fees += actual_quantity*sku.price_with_fee
        commit.product.save(validate: false)
      else
        # update purchase order
        if order['quantity'].to_i == 0
          find_po.first.delete_order
        else
          po = find_po.first
          if sku.inventory >= order['quantity'].to_i - po.quantity
            actual_quantity = order['quantity'].to_i
            message = "Order updated."
          else
            order_difference = order['quantity'].to_i - po.quantity
            actual_quantity = po.quantity + sku.inventory
            message = "Only enough inventory for #{actual_quantity} on your order of #{sku.description}, we updated your order to this amount."
          end
          total_difference += actual_quantity.to_i - po.quantity
          if po.quantity != order['quantity'].to_i
            sku.inventory -= actual_quantity.to_i - po.quantity
            commit.amount += actual_quantity.to_i - po.quantity
            og_sale_amount = commit.sale_amount
            og_sale_amount_with_fees = commit.sale_amount_with_fees
            commit.sale_amount += (actual_quantity.to_i - po.quantity)*sku.discount_price
            commit.sale_amount_with_fees += (actual_quantity.to_i - po.quantity)*sku.price_with_fee
            commit.save!
            commit.product.current_sales += commit.sale_amount - og_sale_amount
            commit.product.current_sales_with_fees += commit.sale_amount_with_fees - og_sale_amount_with_fees
            commit.product.save!

            po.quantity = actual_quantity
            sku.save!
            po.save!
          end

        end
      end
    end
    message
  end

  def create_new_commit(orders, product)
    commit = Commit.create
    total_price = 0
    total_price_with_fee = 0
    total_quantity = 0
    message = nil
    commit.full_price = false
    commit.status = 'live'
    orders.each do |order|
      sku = Sku.find(order['sku'])
      new_purchase_order(order['quantity'], sku, commit, false)
      total_price += order['quantity'].to_i*sku.discount_price
      total_price_with_fee += order['quantity'].to_i*sku.price_with_fee
      total_quantity += order['quantity'].to_i
    end
    commit.amount = total_quantity
    commit.product_id = product.id
    commit.sale_amount = total_price
    commit.sale_amount_with_fees = total_price_with_fee
    commit.set_commit(current_user)
    commit.product.current_sales += commit.sale_amount
    commit.product.current_sales_with_fees += commit.sale_amount_with_fees
    commit.product.save(validate: false)
    message
  end

  def full_price_commit
    orders = JSON.parse(params[:orders])
    product = Product.find(params[:product])
    commit = Commit.create
    commit.full_price = true
    commit.status = 'full_price'
    total_price = 0
    total_quantity = 0
    orders.each do |order|
      sku = Sku.find(order['sku'])
      new_purchase_order(order['quantity'], sku, commit, true)
      total_price += order['quantity'].to_i*sku.price
      total_quantity += order['quantity'].to_i
    end
    commit.amount = total_quantity
    commit.product_id = product.id
    commit.sale_amount = total_price
    commit.sale_amount_with_fees = total_price
    commit.set_commit(current_user)
    commit.product.current_sales += commit.sale_amount
    commit.product.current_sales_with_fees += commit.sale_amount_with_fees
    commit.product.save(validate: false)
    render :json => {success: true}
  end

  def delete_purchase_order
    order = PurchaseOrder.find(params[:order])
    if order.commit.amount - order.quantity >= order.sku.product.minimum_order
      order.delete_order
      flash[:success] = "#{order.sku.description} deleted."
    else
      flash[:error] = "Total order amount must be at least #{order.sku.product.minimum_order}, deleting this order would result in an order amount of #{order.commit.amount - order.quantity}, you can cancel your entire order at the bottom of this page."
    end
    return redirect_to request.referrer
  end

  def delete_commit
    commit = Commit.find_by(:uuid => params[:commit])
    if !commit.nil?
      commit.purchase_orders.each do |po|
        po.delete_order
      end
      flash[:success] = "Order cancelled"
    end
    return redirect_to request.referrer
  end

  def new_purchase_order(quantity, sku, commit, full_price)
    full_price ||= false
    po = PurchaseOrder.new
    po.commit_id = commit.id
    po.sku_id = sku.id
    if sku.inventory.to_i >= quantity.to_i
      actual_quantity = quantity.to_i
      message = "Order completed."
    else
      actual_quantity = sku.inventory
      message = "Only enough inventory for #{actual_quantity} of your order of #{sku.description}, we updated your order to this amount."
    end
    po.quantity = actual_quantity
    sku.inventory -= actual_quantity
    po.full_price = full_price
    po.sale_made = full_price
    sku.save!
    po.save!
    return actual_quantity
  end

  def submit_rating
    rating = Rating.find(params[:id])
    rate = params[:rating].to_i
    comment = params[:comment]
    if rate < 4 && (comment.nil? || comment.length < 8)
      flash[:error] = "If you're rating is less than 4, you must leave a substantial comment."
      return redirect_to request.referrer
    end
    wholesaler = rating.sale.commit.wholesaler
    wholesaler.total_number_ratings += 1
    wholesaler.total_rating += rate
    wholesaler.save!
    rating.rating = rate
    rating.comment = comment
    rating.save!
    return redirect_to request.referrer
  end

end
