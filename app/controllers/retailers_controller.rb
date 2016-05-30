class RetailersController < ApplicationController

  def index
    authneticate_retailer
    @pending_orders = Commit.where('user_id = ? AND status = ?', current_user.id, 'live')
  end

end
