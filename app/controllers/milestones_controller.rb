class MilestonesController < ApplicationController

  def create
    milestone = Milestone.create(milestone_params)
    redirect_to request.referrer
  end

  private
  def milestone_params
    params.require(:milestone).permit(:goal, :product_id, :batch_id)
  end

end
