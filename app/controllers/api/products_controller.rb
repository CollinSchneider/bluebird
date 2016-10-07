class Api::ProductsController < ApiController

  def extend_product
    product = Product.find_by_uuid(params[:uuid])
    product.end_time = Time.now + 10.days
    product.status = 'live'
    if product.save(validate: false)
      product.commits.each do |commit|
        commit.status = 'live'
        commit.save(validate: false)
        # BlueBirdEmail.retailer_product_extended(commit.retailer.user, product)
      end
      render :json => {
        success: true,
        product: product
      }
    else
      render :json => {
        success: false,
        errors: product.errors
      }
    end
  end

  def grant_discount
    product = Product.find(params[:product_id])
    product.status = 'discount_granted'
    product.save
    render :json => {:product => product}
    product.commits.each do |commit|
      commit.status = 'discount_granted'
      commit.sale_made = true
      current_user.collect_payment(commit)
      commit.save(validate: false)
      BlueBirdEmail.retailer_discount_hit(commit.retailer.user, commit, product)
    end
  end

  def expire_product
    product = Product.find(params[:product_id])
    pt = ProductToken.new
    pt.product_id = product.id
    pt.token = SecureRandom.uuid
    pt.expiration_datetime = (Time.now + 7.days + 1.hour).beginning_of_hour
    pt.save

    original_inventory = product.quantity.to_i
    product.commits.each do |commit|
      original_inventory += commit.amount.to_i
      BlueBirdEmail.retailer_discount_missed(commit.retailer.user, product)
      commit.status = 'past'
      commit.sale_made = false
      commit.save(validate: false)
    end
    product.status = 'full_price'
    product.current_sales = 0
    product.quantity = original_inventory
    product.save(validate: false)
    render :json => {:product => product}
  end

end
