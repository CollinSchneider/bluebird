class Api::CompanyController < ApiController

  def remove_logo
    company = Company.find(params[:company])
    company.logo.clear
    company.save!
    return redirect_to request.referrer
  end

end
