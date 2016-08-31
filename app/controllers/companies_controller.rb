class CompaniesController < ApplicationController

  def update
    company = Company.find(params[:id])
    company.update(company_params)
    if company.save(validate: false)
      redirect_to request.referrer
      flash[:success] = "Company updated!"
    else
      flash[:error] = company.errors
    end
  end

  private
  def company_params
    params.require(:company).permit(:company_name, :location, :bio, :logo)
  end

end
