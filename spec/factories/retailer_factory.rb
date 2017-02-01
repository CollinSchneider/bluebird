FactoryGirl.define do

  factory :retailer do
    association :user, factory: :retail_user
  end

end
