class SubscriptionPayment < ActiveRecord::Base

  belongs_to :wholesaler

  validate :no_other_subscriptions_this_month

  def no_other_subscriptions_this_month
    binding.pry
    wholesaler.subscription_payments.where('due_at ')
  end

  def pay_date_is_first
    if due_at.day != 1
      errors.add(base: "Due Date must be the first of the month")
    end
  end

end
