require 'rails_helper'

feature 'User signs in' do

  let(:user) {FactoryGirl.create(:user)}
  let(:unapproved_user) {FactoryGirl.create(:user, :unapproved)}
  let(:retailer) {FactoryGirl.create(:retailer)}
  let(:wholesaler) {FactoryGirl.create(:wholesaler)}
  let(:admin) {FactoryGirl.create(:admin)}

  before(:each) do
    visit users_path
  end

  it 'should flash No users found with this email' do
    login('no_email', 'fake_password')

    expect(page).to have_content('No users found with this email')
  end

  it 'should flash incorrect password' do
    login(user.email, 'passworddddd')

    expect(page).to have_content('Incorrect password')
  end

  it 'should flash user not approved yet' do
    login(unapproved_user.email, unapproved_user.password)

    expect(page).to have_content('Your application has not yet been approved')
  end

  it 'should login retailer' do
    login(retailer.user.email, retailer.user.password)

    expect(page).to have_content('Filter Products')
  end

  it 'should login wholesaler' do
    login(wholesaler.user.email, wholesaler.user.password)

    expect(page).to have_content('Current Sales')
  end

  it 'should login admin' do
    login(admin.user.email, admin.user.password)

    expect(page).to have_content('Pending Wholesalers')
  end

  def login(email, password)
    fill_in 'email', with: email
    fill_in 'password', with: password
    within('form') do
      click_on 'Login'
    end
  end

end
