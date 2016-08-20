class CompaniesController < ApplicationController

  def update
    company = Company.find(params[:id])
    company.update(company_params)
    redirect_to request.referrer
    flash[:success] = "Company updated!"
  end

  private
  def company_params
    params.require(:company).permit(:company_name, :location, :bio)
  end

end
