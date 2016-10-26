class Api::AdminController < ApiController

  def approve
    if current_user.is_admin?
      user = User.find_by(:uuid => params[:uuid])
      user.approved = true
      user.save!
      if user.is_wholesaler?
        BlueBirdEmail.wholesaler_welcome_email(user)
      elsif user.is_retailer?
        BlueBirdEmail.retailer_welcome_email(user)
      end
      return render :json => {
        success: true,
        message: "Approved #{user.company.company_name}"
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
