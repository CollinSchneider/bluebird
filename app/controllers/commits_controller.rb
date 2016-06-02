class CommitsController < ApplicationController

  def create
    commit = Commit.create(commit_params)
    # if Time.now < commit.product.batch.end_time
      if commit.amount <= commit.product.quantity
        commit.product.quantity -= commit.amount
        commit.product.save
        commit.status = 'live'
        commit.save
      else
        commit.delete
        flash[:error] = "Sorry, only #{commit.product.quantity} in inventory!"
      end
    # else
      # flash[:error] = "Sorry, this batch has just ended!"
    # end
    redirect_to request.referrer
  end

  def show
    @commit = Commit.find(params[:id])
    authenticate_retailer_commit(@commit)
  end

  def update
    commit = Commit.find(params[:id])
    commit.update(commit_params)
    redirect_to product_path(commit.product_id)
  end

  def destroy
    commit = Commit.find(params[:id])
    commit.product.quantity += commit.amount
    commit.product.save
    commit.destroy
    redirect_to shop_path
  end


  private
  def commit_params
    params.require(:commit).permit(:user_id, :product_id, :amount, :status)
  end

end
