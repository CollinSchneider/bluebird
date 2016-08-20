class Api::PaymentsController < ApiController

  def create_credit_card
    token = params[:token]
    Stripe.api_key = ENV['STRIPE_SECRET_KEY']
    customer = Stripe::Customer.retrieve(current_user.retailer.stripe_id)
    begin
      card = customer.sources.create(:source => token)
      if !card.nil?
        render :json => {:success => true}
      end
    rescue Stripe::CardError => e
      flash[:error] = e.message
      render :json => {
        :success => false,
        :error => e.message
      }
    end
  end

  def make_default_card
    card_id = params[:card_id]
    Stripe.api_key = ENV['STRIPE_SECRET_KEY']
    customer = Stripe::Customer.retrieve(current_user.retailer.stripe_id)
    customer.default_source = card_id
    if customer.save
      render :json => {success: true}
    else
      render :json => {success: false}
    end
  end

  def charge_user
    commit = Commit.find(params[:commit_id])
    shipping_cost = 30
    charge = current_user.collect_payment(commit)
    render :json => {charge: charge}
  end

  def change_commit_card
    commit = Commit.find(params[:commit_id])
    card_id = params[:card_id]
    commit.card_id = card_id
    if commit.card_declined
      commit.card_declined = false
      commit.card_decline_date = nil
    end
    if commit.save
      render :json => {success: true}
    else
      render :json => {success: false}
    end
  end

end
