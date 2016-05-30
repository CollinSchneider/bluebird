class ProductItemsController < ApplicationController

  def create
    product = ProductItem.create(product_item_params)
    redirect_to request.referrer
  end

  private
  def product_item_params
    params.require(:product_item).permit(:description, :quantity, :product_id)
  end

end
