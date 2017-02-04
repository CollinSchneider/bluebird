class Api::PaymentsController < ApiController

  def create_credit_card
    token = params[:token]
    Stripe.api_key = ENV['STRIPE_SECRET_KEY']
    stripe_id = current_user.is_retailer? ? current_user.retailer.stripe_id : current_user.wholesaler.stripe_customer_id
    customer = Stripe::Customer.retrieve(stripe_id)
    begin
      card = customer.sources.create(:source => token)
      if !card.nil?
        if current_user.is_wholesaler?
          current_user.wholesaler.create_next_month_subscription(card.id)
        end
        render :json => {
          :success => true,
          :card => card
        }
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


  def delete_credit_card
    card_id = params[:card_id]
    if commit = current_user.retailer.commits.where("card_id = ? AND status = ?", card_id, 'live').first
      return render :json => {
        success: false,
        commit: commit.id
      }
    else
      customer = Stripe::Customer.retrieve(current_user.retailer.stripe_id)
      card = customer.sources.retrieve(card_id).delete
      return render :json => {success: true}
    end
  end

  def change_commit_card
    commit = Commit.find_by_uuid(params[:commit_uuid])
    card_id = params[:card_id]
    commit.card_id = card_id
    commit.save(validate: false)
    if !commit.sale.nil? && commit.sale.card_failed

      charge = commit.product.wholesaler.user.collect_payment(commit)
      if charge[1]
        commit.save(validate: false)
        return render :json => {
          success: true,
          charge: charge[0]
        }
      else
        return render :json => {
          success: false,
          error: charge[0]
        }
      end

    elsif !commit.shipping.nil? && commit.shipping.card_failed

      charge = commit.product.wholesaler.user.collect_shipping_charge(commit)
      if charge[1]
        commit.save(validate: false)
        return render :json => {success: true}
      else
        return render :json => {
          success: false,
          error: charge[0]
        }
      end

    end
    return render :json => {success: true}
  end

  #TODO Come back for sending a refund email, need to figure out dynamically inserting the reason, or should this be manual
  def refund_order
    Stripe.api_key = ENV['STRIPE_SECRET_KEY']
    order = Commit.find(params[:order_id])
    charge = Stripe::Charge.retrieve(order.sale.stripe_charge_id, :stripe_account => order.product.wholesaler.stripe_id)
    begin
      refund = charge.refunds.create(:amount => charge.amount, :refund_application_fee => true)
    rescue => e
      return render :json => {
        success: false,
        error: e.message
      }
    end
    if !refund.nil?
      order.refunded = true
      order.sale_made = false
      product_sales = order.product.current_sales.to_f
      new_sales = order.full_price ? product_sales+order.amount.to_f*order.product.price.to_f : product_sales+order.amount.to_f*order.product.discount.to_f
      order.product.current_sales = new_sales
      order.save(validate: false)
      return render :json => {
        success: true,
        order: order,
        charge: charge,
        refund: refund
      }
    end
  end

end
