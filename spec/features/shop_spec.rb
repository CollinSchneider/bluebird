require 'rails_helper'

feature 'Visit shop path' do

  let(:user) { FactoryGirl.create(:user) }
  let(:product) { FactoryGirl.create(:live_product) }
  let(:retailer) { FactoryGirl.create(:retailer) }
  let(:wholesaler) { FactoryGirl.create(:wholesaler) }
  let(:admin) { FactoryGirl.create(:admin) }
  let(:home_product_category) { FactoryGirl.create(:home_product_category) }

  before(:each) do
    product
    login
  end

  it 'should have live products visible' do
    expect(page).to have_current_path('/shop')
    expect(page).to have_content(product.title)
  end

  def login
    visit users_path
    fill_in 'email', with: retailer.user.email
    fill_in 'password', with: retailer.user.password
    within('form') do
      click_on 'Login'
    end
  end

end
