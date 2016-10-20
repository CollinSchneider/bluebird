class Api::OrdersController < ApiController

  def make_purchase_order
    orders = JSON.parse(params[:orders])
    product = Product.find(params[:product])
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
    order.delete_order
    flash[:success] = "#{order.sku.description} deleted."
    return redirect_to request.referrer
  end

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
