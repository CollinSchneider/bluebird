require 'rails_helper'

describe User do

  # let(:user) {FactoryGirl.create(:user, :approved)}

  it 'has a valid factory' do
    user = build(:user)
    user_2 = build(:user)
    # expect(user.valid?).to eq true
    # expect(user_2.valid?).to eq false
  end

end
