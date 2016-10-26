class Api::ProductsController < ApiController

  def create_skus
    if request.post?
      product = Product.find_by(:uuid => params[:uuid])
      if !product.nil?
        if !product.product_sizings.any? && !product.product_variants.any?
          if Sku.find_by(:code => "#{product.id}-0-0").nil?
            sku = Sku.new
            sku.code = "#{product.id}-0-0"
            sku.product_id = product.id
            sku.save!
            product.has_skus = false
            product.save(validate: false)
            return redirect_to "/new_product_skus?product=#{product.uuid}&sku=#{product.skus.first.id}"
          end
        elsif !product.product_sizings.any?
          product.product_variants.each do |var|
            if Sku.find_by(:code => "#{product.id}-#{var.id}-0").nil?
              sku = Sku.new
              sku.product_id = product.id
              sku.product_variant_id = var.id
              sku.code = "#{product.id}-#{var.id}-0"
              sku.save!
            end
          end
        elsif !product.product_variants.any?
          product.product_sizings.each do |size|
            if Sku.find_by(:code => "#{product.id}-0-#{size.id}").nil?
              sku = Sku.new
              sku.product_id = product.id
              sku.product_sizing_id = size.id
              sku.code = "#{product.id}-0-#{size.id}"
              sku.save!
            end
          end
        else
          product.product_sizings.each do|size|
            product.product_variants.each do |var|
              if Sku.find_by(:code => "#{product.id}-#{var.id}-#{size.id}").nil?
                sku = Sku.new
                sku.product_id = product.id
                sku.product_sizing_id = size.id
                sku.product_variant_id = var.id
                sku.code = "#{product.id}-#{var.id}-#{size.id}"
                sku.save!
              end
            end
          end
        end
        product.has_skus = true
        product.save(validate: false)
        return redirect_to "/new_product_skus?product=#{product.uuid}&sku=#{product.skus.order(id: :asc).first.id}"
      end
    end
  end

  def create_size
    product = Product.find_by(:uuid => params[:product])
    size = params[:size]
    if product.product_sizings.where('description = ?', size).any?
      return render :json => {
        success: false,
        message: "#{product.title} already has this size."
      }
    else
      new_size = ProductSizing.new
      new_size.description = size
      new_size.product_id = product.id
      new_size.save!
      return render :json => {
        success: true,
        size: new_size,
        total_sizes: new_size.product.product_sizings.count
      }
    end
  end

  def remove_size
    size = ProductSizing.find(params[:size])
    if size.product.wholesaler.id == current_user.wholesaler.id
      count = size.product.product_sizings.count - 1
      size.delete
      return render :json => {
        success: true,
        size: size,
        total_sizes: count
      }
    else
      return render :json => {
        success: false,
        message: "Only the product owner can delete a size."
      }
    end
  end

  def remove_variant
    variant = ProductVariant.find(params[:variant])
    if variant.product.wholesaler_id == current_user.wholesaler.id
      variant.image.clear
      variant.save!
      variant.delete
      return render :json => {success: true}
    else
      return render :json => {
        success: false,
        message: "Only the product owner can delete a product variant"
      }
    end
  end

  def has_no_variants
    @product = Product.find_by(:uuid => params[:product])
    missing_skus = @product.product_sizings.where('id not in (
      select product_sizing_id from skus where product_id = ?
    )', @product.id)
    if missing_skus.any?
      missing_skus.each do |size|
        sku = Sku.new
        sku.product_id = @product.id
        sku.product_sizing_id = size.id
        sku.code = "#{@product.id}-0-#{size.id}"
        sku.save!
      end
    elsif !@product.skus.any?
      sku = Sku.new
      sku.product_id = @product.id
      sku.code = "#{@product.id}-0-0"
      sku.save!
    end
    sku = @product.skus.where('inventory is null or price is null or suggested_retail is null').first
    return redirect_to "/new_product_skus?product=#{@product.uuid}&sku=#{sku.id}"
  end

  def remove_sku
    sku = Sku.find(params[:sku])
    if sku.product.wholesaler_id == current_user.wholesaler.id
      var = sku.product_variant
      sku.delete
        # if sku.product_variant.present?
        #   sku.product_variant.delete
        # end
        # if sku.product_sizing.present?
        #   sku.product_sizing.delete
        # end
      return render :json => {success: true}
    else
      return render :json => {
        success: false,
        message: "Only the product owner can delete a product SKU"
      }
    end
  end

  def extend_product
    product = Product.find_by_uuid(params[:uuid])
    product.end_time = Time.current + 10.days
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
      commit.purchase_orders.each do |po|
        po.sale_made = true
        po.save!
      end
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
    pt.expiration_datetime = (Time.current + 7.days + 1.hour).beginning_of_hour
    pt.save

    product.skus.each do |sku|
      sku_inventory = 0
      sku.purchase_orders.each do |po|
        sku_inventory += po.quantity
      end
      sku.inventory += sku_inventory
    end

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
    product.current_sales_with_fees = 0
    product.quantity = original_inventory
    product.save(validate: false)
    render :json => {:product => product}
  end

end
