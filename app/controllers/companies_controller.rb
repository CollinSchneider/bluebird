class CompaniesController < ApplicationController

  def update
    company = Company.find(params[:id])
    if company.user_id == current_user.id
      company.update(company_params)
      if company.save(validate: false)
        flash[:success] = "Company updated!"
        return redirect_to request.referrer
      else
        flash[:error] = company.errors
        return redirect_to request.referrer
      end
    end
  end

  private
  def company_params
    params.require(:company).permit(:company_name, :location, :bio, :logo)
  end

end
