class CompaniesController < ApplicationController

  def update
    company = Company.find(params[:id])
    if company.user_id == current_user.id
      og_file_url = company.logo.url
      og_logo = company.logo
      company.update(company_params)
      company.save(validate: false)
      flash[:success] = "Company updated!"
      return redirect_to request.referrer
    end
  end

  private
  def company_params
    params.require(:company).permit(:company_name, :location, :bio, :logo, :contact_email, :contact_number)
  end

end
