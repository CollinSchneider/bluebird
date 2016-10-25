class Api::AdminController < ApiController

  def approve
    id = params[:id]
    customer_type = params[:user] === 'wholesaler' ? Wholesaler : Retailer
    customer = customer_type.find(params[:id])
    customer.approved = true
    if customer.save
      if customer_type == 'wholesaler'
        BlueBirdEmail.wholesaler_welcome_email(customer.user)
      else
        BlueBirdEmail.retailer_welcome_email(customer.user)
      end
      return render :json => {
        success: true,
        message: "Approved #{customer.user.company.company_name}"
      }
    else
      return render :json => {
        success: false,
        message: "Error: #{customer.user.company.company_name} could not be approved"
      }
    end
  end

  #TODO congrats email?
  def feature_product
    if current_user.is_admin?
      product = Product.find(params[:product_id])
      product.featured = true
      if product.save(validate: false)
        render :json => {
          success: true,
          product: product
        }
      else
        render :json => {
          success: false,
          errors: products.errors
        }
      end
    end
  end

  def un_feature_product
    if current_user.is_admin?
      product = Product.find(params[:product_id])
      product.featured = false
      if product.save(validate: false)
        render :json => {
          success: true,
          product: product
        }
      else
        render :json => {
          success: false,
          errors: products.errors
        }
      end
    end
  end

  def expire_products
    if current_user.is_admin?
      products = Product.expire_products
      return render :json => {
        goal_met: products[0],
        needs_attention: products[1]
      }
    end
  end

end
