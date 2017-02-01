FactoryGirl.define do

  factory :live_product, class: Product do
    title "Blankets"
    status "live"
    category 'home-goods'
    main_image { fixture_file_upload(Rails.root.join('spec', 'example_files', 'images', 'fake-pic.png'), 'image/jpg') }
    # skus {[
    #     FactoryGirl.create(:sku)
    #   ]}
    duration "7_days"
    start_time { Time.now - 1.day }
    end_time { Time.now + 6.days }
    wholesaler { FactoryGirl.create(:wholesaler) }
    long_description "long description.............."
    short_description "short description."
    feature_one "feature one"
    minimum_order 5
    goal 1000
    current_sales 0
    percent_discount 10

    factory :sku, class: Sku do
      product_variant { FactoryGirl.create(:product_variant) }
      # hard coding price to match products percent_discount
      price 20
      discount_price 18
      price_with_fee 18.4
      suggested_retail 40
      inventory 100
    end
  end

end
