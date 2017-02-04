class CompaniesController < ApplicationController

  def update
    company = Company.find(params[:id])
    if company.user_id == current_user.id
      # og_file_url = company.logo.url
      # og_logo = company.logo
      company.update(company_params)
      company.save(validate: false)
      if company.user.wholesaler.return_policy_id != params[:return_policy].to_i || company.user.wholesaler.shipping_policy != params[:shipping_policy]
        company.user.wholesaler.shipping_policy = params[:shipping_policy]
        company.user.wholesaler.return_policy_id = params[:return_policy]
        company.user.wholesaler.save(validate: false)
      end
      flash[:success] = "Company updated!"
      return redirect_to request.referrer
    end
  end

  def show
    @company = Company.find_by(:company_key => params[:key], :id => params[:id])
    return redirect_to '/shop' if @company.nil?
    @title = @company.company_name
    @products = Product.where('wholesaler_id = ? AND status = ? AND end_time >= ?', @company.user.wholesaler.id, 'live', Time.current)
  end

  def ratings
    @company = Company.find_by(:company_key => params[:key], :id => params[:id])
    return redirect_to '/shop' if @company.nil?
    @title = "#{@company.company_name} Ratings"
    @ratings = @company.ratings.order(created_at: :desc).page(params[:page]).per_page(6)
  end

  def contact
    @company = Company.find_by(:company_key => params[:key], :id => params[:id])
    return redirect_to '/shop' if @company.nil?
    return redirect_to "/company/#{@company.id}/#{@company.company_key}" if @company.contact_email.nil? || @company.contact_email.length < 2
    @title = "Contact #{@company.company_name}"

    if request.post?
      company = Company.find(params[:company])
      from_email = current_user.email
      from_name = current_user.full_name
      to_email = company.contact_email
      message = params[:message]
      BlueBirdEmail.contact_company(from_email, from_name, to_email, message)
      render :json => {success: true}
    end
  end

  private
  def company_params
    params.require(:company).permit(:company_name, :location, :bio, :logo, :contact_email, :contact_number)
  end

end
