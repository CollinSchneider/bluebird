class CommitsController < ApplicationController
  before_action :redirect_if_not_retailer

  def create
    if current_user.is_retailer?
      commit = Commit.create(commit_params)
      if commit.set_commit(current_user)
        commit.product.quantity -= commit.amount
        commit.product.current_sales = commit.product.current_sales.to_f + commit.amount.to_f*commit.product.discount.to_f
        commit.product.save(validate: false)

        if params[:full_price] == 't'
          commit.full_price = true
          commit.status = 'full_price'
          commit.sale_made = true
          commit.save(validate: false)
          charge = commit.product.wholesaler.user.collect_payment(commit)
          if !charge.nil? && !charge[1]
            return redirect_to "/retailer/#{commit.uuid}/card_declined"
          else
            BlueBirdEmail.retailer_full_price_email(commit, commit.retailer.user)
            BlueBirdEmail.wholesaler_full_price_email(commit, commit.product.wholesaler.user)
            return redirect_to '/retailer/order_history'
          end
        else
          # Not full price
        end
      else
        # Didn't save
        flash[:error] = commit.errors.full_messages
      end
      # return to same page if it saves or not
      return redirect_to request.referrer
    end
  end

  def update
    commit = Commit.find(params[:id])
    if commit.retailer_id == current_user.retailer.id
      og_quantity = commit.amount
      og_sale_amount = commit.sale_amount

      commit.update(commit_params)
      commit_difference = commit.amount - og_quantity
      sale_difference = commit_difference*commit.product.discount.to_f
      commit.sale_amount = og_sale_amount.to_f + sale_difference.to_f
      if commit.save
        commit.product.quantity -= commit_difference
        new_sales = commit.product.current_sales.to_f + sale_difference
        commit.product.current_sales = new_sales
        commit.product.save(validate: false)
      else
        flash[:error] = commit.errors.full_messages
      end
      return redirect_to "/products/#{commit.product.id}/#{commit.product.slug}"
    end
  end

  def destroy
    commit = Commit.find(params[:id])
    product = Product.find(commit.product_id)
    if commit.retailer_id == current_user.retailer.id
      commit.destroy_commit
      return redirect_to "/products/#{product.id}/#{product.slug}"
    end
  end

  private
  def commit_params
    params.require(:commit).permit(:user_id, :product_id, :amount, :status, :uuid, :full_price, :retailer_id)
  end

  def redirect_if_not_retailer
    redirect_to "/users" if current_user.nil?
    redirect_to "/wholesaler" if current_user.is_wholesaler?
  end

end
