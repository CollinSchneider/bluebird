FactoryGirl.define do

  factory :product_variant, class: ProductVariant do
    product { FactoryGirl.create(:live_product) }
    description "Random product variant description"
    image { fixture_file_upload(Rails.root.join('spec', 'example_files', 'images', 'fake-pic.png'), 'image/jpg') }
  end

end
