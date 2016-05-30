class WholesalersController < ApplicationController

  def index
    authenticate_wholesaler
    Stripe.api_key = ENV["STRIPE_SECRET_KEY"]
    @stripe_customer = Stripe::Customer.retrieve(current_user.stripe_customer_id)
    @current_batches = Batch.where('user_id = ? AND status = ?', current_user.id, 'live')
    # get_current_sales(@current_batches[0])
    @batches_need_attention = Batch.where('user_id = ? AND completed_status = ?', current_user.id, 'needs_attention')
    @past_batches = Batch.where('user_id = ? AND status = ?', current_user.id, 'past')
    # @past_batches = Batch.where('user_id = ? AND status = ? AND completed_status = ?', current_user.id, 'past', nil)
  end

  def get_current_sales(batches)
    if batches > 0
      @current_sales = 0
      batch.products.each do |product|
        product.commits.each do |commit|
          @current_sales += commit.amount.to_f*commit.product.discount.to_f
        end
      end
    end
  end

  def past_batches
    @past_batches = Batch.where('user_id = ? AND status = ?', current_user.id, 'past').order(end_time: :asc)
  end

end
