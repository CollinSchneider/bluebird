class Retailers::FavoritesController < RetailersController

  def index
    wholesaler_ids = current_user.retailer.favorite_sellers.collect(&:wholesaler_id)
    @products = Product.where('wholesaler_id in (?) and end_time > ?', wholesaler_ids, Time.now).page(params[:page]).per_page(6)
  end

  def manage
    @favorite_sellers = current_user.retailer.favorite_sellers
  end

  def remove
    favorite = FavoriteSeller.find(params[:id])
    favorite.destroy
    flash[:success] = "#{favorite.wholesaler.company.company_name} removed from favorites."
    redirect_to request.referrer
  end

  def add
    wholesaler = Wholesaler.find(params[:wholesaler_id])
    FavoriteSeller.create(:wholesaler_id => wholesaler.id, :retailer_id => current_user.retailer.id)
    flash[:success] = "#{wholesaler.user.company.company_name} added to your favorites."
    redirect_to request.referrer
  end

end
