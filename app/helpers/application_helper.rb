module ApplicationHelper

  def current_user
    if session[:user_id]
      current_user = current_user || User.find(session[:user_id])
    end
  end

  def authenticate_anybody
    redirect_to "/users" unless !current_user.nil?
  end

  def authenticate_retailer
    redirect_to "/users" unless !current_user.nil?
    if current_user
      if current_user.is_retailer?
        @retailer = current_user.retailer
      else
        redirect_to wholesaler_path unless current_user.is_retailer?
      end
    end
  end

  def authenticate_wholesaler
    redirect_to "/users" unless !current_user.nil?
    if current_user
      redirect_to shop_path unless current_user.is_wholesaler?
    end
  end

  def authenticate_wholesaler_product(product)
    redirect_to "/users" unless !current_user.nil?
    if current_user
      redirect_to wholesaler_path unless product.user.email == current_user.email
    end
  end

  def authenticate_retailer_commit(commit)
    redirect_to "/users" unless !current_user.nil?
    if current_user
      redirect_to retailer_path unless current_user.id == commit.user_id
    end
  end

end
