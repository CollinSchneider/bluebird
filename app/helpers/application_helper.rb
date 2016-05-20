module ApplicationHelper

  def current_user
    if session[:user_id]
      current_user = current_user || User.find(session[:user_id])
    end
  end

  def authenticate_anybody
    redirect_to root_path unless current_user
  end

  def authneticate_retailer
    redirect_to root_path unless current_user
    if current_user
      redirect_to wholesaler_path unless current_user.user_type == 'retailer'
    end
  end

  def authenticate_wholesaler
    redirect_to root_path unless current_user
    if current_user
      redirect_to products_path unless current_user.user_type == 'wholesaler'
    end
  end

  def authenticate_wholesaler_product(product)
    redirect_to root_path unless current_user
    if current_user
      redirect_to wholesaler_path unless product.user.email == current_user.email
    end
  end

end
