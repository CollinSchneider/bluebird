class PurchaseOrdersController < ApplicationController

  def destroy
    po = PurchaseOrder.find(params[:id])
    po.destroy
    flash[:success] = "Purchase order deleted"
    redirect_to shop_path
  end

end
