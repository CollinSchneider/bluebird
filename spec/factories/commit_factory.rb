FactoryGirl.define do

  factory :commit, class: Commit do
    product { FactoryGirl.create(:live_product) }
    wholesaler { FactoryGirl.create{:wholesaler} }
    amount 10
    status 'live'
    card_id 'fake_stripe_card_id'

    factory :purchase_order, class: PurchaseOrder do
      sku { FactoryGirl.create(:sku) }
      quantity 10
      # sale_amount sku.discount_price*quantity
      # sale_amount_with_fees sku.price_with_fee*quantity
    end
  end

end
