class WholesalersController < ApplicationController

  def index
    authenticate_wholesaler
    @current_batch = Batch.where('user_id = ? AND status = ?', current_user.id, 'live')
    @past_batches = Batch.where('user_id = ? AND status = ?', current_user.id, 'past')
    # @past_batches = Batch.where('user_id = ? AND status = ? AND completed_status = ?', current_user.id, 'past', nil)
  end

end
