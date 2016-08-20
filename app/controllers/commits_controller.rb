class CommitsController < ApplicationController

  def create
    commit = Commit.create(commit_params)
    # if Time.now < commit.product.end_time
      if commit.amount <= commit.product.quantity
        commit.product.quantity -= commit.amount
        commit.product.current_sales = commit.product.current_sales.to_f + commit.amount.to_f*commit.product.discount.to_f
        commit.product.save
        commit.retailer_id = current_user.retailer.id
        commit.set_primary_card_id
        commit.save
      else
        commit.destroy
        flash[:error] = "Sorry, only #{commit.product.quantity} in inventory!"
      end
    # else
    #   commit.destroy
    #   flash[:error] = "Nice try, this product expired"
    # end
    redirect_to request.referrer
  end

  def show
    @commit = Commit.find(params[:id])
    # authenticate_retailer_commit(@commit)
  end

  def edit
    commit = Commit.find(params[:id])
  end

  def update
    commit = Commit.find(params[:id])
    commit.update(commit_params)
    # if commit.amount >= commit.product.quantity
    #   if commit.save(verify: false)
    #     commit.product.quantity
    #   end
    # end
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
    params.require(:commit).permit(:user_id, :product_id, :amount, :status, :uuid)
  end

end
