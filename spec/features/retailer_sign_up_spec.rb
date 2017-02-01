require 'rails_helper'

feature 'Retailer signs up' do

  let(:user) { FactoryGirl.create(:user) }

  before(:each) do
    user
    visit "/signup"
  end

  it "should not let you signup because email is taken" do
    fill_in 'Company Name', with: "Some Company Name"
    fill_in 'First Name', with: "Collin"
    fill_in 'Last Name', with: "Schneider"
    fill_in 'Email', with: user.email
    fill_in 'Phone Number (BlueBird Use Only)', with: '(203) 233-1234'
    fill_in 'Password', with: 'password'
    fill_in 'Confirm Password', with: 'password'
    click_on 'Apply'

    expect(page).to have_content('Email has already been taken')
  end

  it "should fail because last name is taken" do
    fill_in 'Company Name', with: "Some Company Name"
    fill_in 'First Name', with: "Collin"
    fill_in 'Email', with: 'fake@email.com'
    fill_in 'Phone Number (BlueBird Use Only)', with: '(203) 233-1234'
    fill_in 'Password', with: 'password'
    fill_in 'Confirm Password', with: 'password'
    click_on 'Apply'

    expect(page).to have_content("Last name can't be blank")
  end

  it "should fail because first name name is blank" do
    fill_in 'Last Name', with: "Schneider"
    fill_in 'Email', with: 'fake@email.com'
    fill_in 'Phone Number (BlueBird Use Only)', with: '(203) 233-1234'
    fill_in 'Password', with: 'password'
    fill_in 'Confirm Password', with: 'password'
    click_on 'Apply'

    expect(page).to have_content("First name can't be blank")
  end

  it "should fail because first name name is blank" do
    fill_in 'First Name', with: "Collin"
    fill_in 'Last Name', with: "Schneider"
    fill_in 'Email', with: 'fake@email.com'
    fill_in 'Phone Number (BlueBird Use Only)', with: '(203) 233-1234'
    fill_in 'Password', with: 'password'
    fill_in 'Confirm Password', with: 'not_the_same_password'
    click_on 'Apply'

    expect(page).to have_content("Password confirmation doesn't match Password")
  end

  it "should signup successfully" do
    fill_in 'First Name', with: "Collin"
    fill_in 'Last Name', with: "Schneider"
    fill_in 'Email', with: 'fake@email.com'
    fill_in 'Phone Number (BlueBird Use Only)', with: '(203) 233-1234'
    fill_in 'Password', with: 'password'
    fill_in 'Confirm Password', with: 'password'
    click_on 'Apply'

    expect(page).to have_content("Thanks for applying, Collin!")
  end

end
