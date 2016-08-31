class CommitsController < ApplicationController

  def create
    commit = Commit.create(commit_params)
      if commit.save
        commit.product.quantity -= commit.amount
        commit.product.current_sales = commit.product.current_sales.to_f + commit.amount.to_f*commit.product.discount.to_f
        commit.product.save
        commit.retailer_id = current_user.retailer.id
        commit.set_primary_card_id
        commit.save

        if commit.full_price
          commit.status = 'full_price'
          commit.save
          amount = commit.product.price.to_f*commit.amount.to_i
          charge = commit.product.wholesaler.user.collect_payment(commit, amount)
          Mailer.retailer_full_price_email(commit, commit.retailer.user)
          Mailer.wholesaler_full_price_email(commit, commit.product.wholesaler.user)
          if !charge.nil? && !charge[1]
            return redirect_to "/retailer/#{commit.uuid}/card_declined"
          end
        end
      else
        flash[:error] = commit.errors.full_messages
      end
    return redirect_to request.referrer
  end

  def update
    commit = Commit.find(params[:id])
    og_quantity = commit.amount
    commit.update(commit_params)
    commit_difference = commit.amount - og_quantity
    if commit.save
      commit.product.quantity -= commit_difference
      commit.product.save(validate: false)
    else
      flash[:error] = commit.errors
    end
    return redirect_to request.referrer
  end

  def destroy
    commit = Commit.find(params[:id])
    commit.product.quantity += commit.amount
    commit.product.save
    commit.destroy
    redirect_to request.referrer
  end

  private
  def commit_params
    params.require(:commit).permit(:user_id, :product_id, :amount, :status, :uuid, :full_price)
  end

end
