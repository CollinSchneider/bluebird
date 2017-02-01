FactoryGirl.define do

  factory :wholesaler do
    association :user, factory: :wholesale_user
  end

end
