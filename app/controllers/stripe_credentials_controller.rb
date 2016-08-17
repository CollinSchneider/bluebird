class StripeCredentialsController < ApplicationController

  def create
    stripe_credential = StripeCredential.create(stripe_credentials_params)
    redirect_to request.referrer
  end

  def update
    stripe_credential = StripeCredential.find(params[:id])
    stripe_credential.update(stripe_credentials_params)
    redirect_to request.referrer
  end

  private
  def stripe_credentials_params
    params.require(:stripe_credential).permit(:stripe_user_id, :stripe_publishable_key, :access_token)
  end

end
