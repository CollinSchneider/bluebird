class CompaniesController < ApplicationController

  def update
    company = Company.find(params[:id])
    if company.user_id == current_user.id
      # og_file_url = company.logo.url
      # og_logo = company.logo
      company.update(company_params)
      company.save(validate: false)
      flash[:success] = "Company updated!"
      return redirect_to request.referrer
    end
  end

  def show
    @company = Company.find_by(:company_key => params[:key], :id => params[:id])
    return redirect_to '/shop' if @company.nil?
    @products = Product.where('wholesaler_id = ? AND status = ? AND end_time >= ?', @company.user.wholesaler.id, 'live', Time.current)
  end

  def ratings
    @company = Company.find_by(:company_key => params[:key], :id => params[:id])
    return redirect_to '/shop' if @company.nil?
    @ratings = @company.ratings.order(created_at: :desc).page(params[:page]).per_page(6)
  end

  private
  def company_params
    params.require(:company).permit(:company_name, :location, :bio, :logo, :contact_email, :contact_number)
  end

end
