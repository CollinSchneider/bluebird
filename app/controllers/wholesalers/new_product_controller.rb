class Wholesalers::NewProductController < WholesalersController

  def new_product
    return redirect_to '/wholesaler/profile' if (current_user.is_wholesaler? && current_user.wholesaler.orders_to_ship.any?) || (current_user.is_wholesaler? && current_user.wholesaler.needs_attention?) || (current_user.is_wholesaler? && current_user.wholesaler.needs_stripe_connect?)
    if request.post?
      @product = Product.create(generic_product_params)
      # product.wholesaler = current_user.wholesaler
      if @product.save
        return redirect_to "/new_product_sizing?product=#{@product.uuid}"
      else
        flash[:error] = @product.errors.full_messages
      end
    end
  end

  def new_product_sizing
    @product = Product.find_by(:uuid => params[:product])
    return redirect_to '/new_product' if @product.nil?
  end

  def new_product_variants
    @product = Product.find_by(:uuid => params[:product])
    return redirect_to '/new_product' if @product.nil?

    if request.post?
      pv = ProductVariant.create(product_variant_params)
      if !pv.save
        flash[:error] = "Only upload .JPG, .PNG, or .GIF images."
      end
      return redirect_to request.referrer
    end
  end

  def new_product_skus
    if request.get?
      @product = Product.find_by(:uuid => params[:product])
      return redirect_to '/new_product' if @product.nil? || (!current_user.is_admin? && @product.wholesaler_id != current_user.wholesaler.id)

      @sku = Sku.find_by(:id => params[:sku])
      return redirect_to '/new_product' if @sku.nil? || @sku.product_id != @product.id
      if !@sku.inventory.nil? && !@sku.suggested_retail.nil? && !@sku.price.nil? && params[:edit].nil?
        sku = @product.skus.where('inventory is null or price is null or suggested_retail is null')
        url = sku.empty? ? "/approve_product/#{@product.id}" : "/new_product_skus?product=#{@product.uuid}&sku=#{sku.first.id}"
        return redirect_to url
      end
    end

    if request.post?
      sku = Sku.find_by(:id => params[:sku])
      if current_user.is_admin? || sku.product.wholesaler_id == current_user.wholesaler.id
        inventory = params[:inventory]
        price = params[:price]
        suggested_retail = params[:suggested_retail]
        sku.inventory = inventory
        sku.price = price
        sku.suggested_retail = suggested_retail
        discount = price.to_f*((100-sku.product.percent_discount.to_f)/100)
        sku.discount_price = discount
        sku.price_with_fee = (discount + ((price.to_f - discount)*Commit::BLUEBIRD_PERCENT_FEE)).round(2)

        if sku.save
          if params['same-inventory'] == "true" || params['same-retail'] == 'true' || params['same-wholesale'] == 'true'
            sku.product.skus.where('id != ?', sku.id).each do |other_sku|
              other_sku.inventory = params['same-inventory'] == 'true' ? inventory : nil
              other_sku.suggested_retail = params['same-retail'] == 'true' ? suggested_retail : nil
              if params['same-wholesale'] == 'true'
                other_sku.price = price
                other_sku.discount_price = discount
                other_sku.price_with_fee = (discount + ((price.to_f - discount)*Commit::BLUEBIRD_PERCENT_FEE)).round(2)
              end
              other_sku.save!
            end
          end
          next_sku = sku.product.skus.where('inventory is null or price is null or suggested_retail is null').first
          url = next_sku.nil? ? "/approve_product/#{sku.product_id}" : "/new_product_skus?product=#{sku.product.uuid}&sku=#{next_sku.id}"
          if next_sku.nil? && current_user.is_admin?
            sku.product.status = 'needs_approval'
            sku.product.save!
          end
          return redirect_to url
        else
          flash[:error] = sku.errors.full_messages
          return redirect_to request.referrer
        end

      end
    end
  end

  def remove_sku
    sku = Sku.find_by(:code => params[:code])
  end

  private
  def generic_product_params
    params.require(:product).permit(:wholesaler_id, :goal, :duration, :title, :short_description, :long_description, :percent_discount, :feature_one, :feature_two,
      :feature_three, :feature_four, :feature_five, :category, :main_image, :photo_two, :photo_three,
      :photo_four, :photo_five, :minimum_order)
  end

  def product_variant_params
    params.require(:product_variant).permit(:description, :image, :product_id)
  end

  def sku_params
    params.require(:sku).permit(:inventory, :price, :suggested_retail)
  end

end
