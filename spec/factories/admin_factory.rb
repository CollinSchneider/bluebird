FactoryGirl.define do

  factory :admin do
    association :user, factory: :admin_user
  end

end
