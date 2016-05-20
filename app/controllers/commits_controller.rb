class CommitsController < ApplicationController

  def create
    commit = Commit.create(commit_params)
    redirect_to request.referrer
  end

  private
  def commit_params
    params.require(:commit).permit(:user_id, :product_id, :amount)
  end

end
