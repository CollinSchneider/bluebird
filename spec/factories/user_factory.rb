FactoryGirl.define do

  factory :user do
    email "user@gmail.com"
    password "user"
    first_name "Fake"
    last_name "User"
    phone_number "(123) 456-7890"
    approved true

    trait :unapproved do
      approved false
    end

  end

  factory :retail_user, class: User do
    email "retailer@gmail.com"
    password "retailer"
    first_name "Retailer"
    last_name "User"
    phone_number "(123) 456-7890"
    approved true

    trait :unapproved do
      approved false
    end
  end

  factory :wholesale_user, class: User do
    email "wholesaler@gmail.com"
    password "wholesaler"
    first_name "Wetailer"
    last_name "User"
    phone_number "(123) 456-7890"
    approved true
    company {FactoryGirl.create(:company)}

    trait :unapproved do
      approved false
    end
  end

  factory :admin_user, class: User do
    email "admin@gmail.com"
    password "admin"
    first_name "Admin"
    last_name "User"
    phone_number "(123) 456-7890"
    approved true

    trait :unapproved do
      approved false
    end
  end

end
