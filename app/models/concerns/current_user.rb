module CurrentUser extend ActiveSupport::Concern

  def current_user
    if session[:user_id]
      current_user = current_user || User.find(session[:user_id])
    end
  end

end
