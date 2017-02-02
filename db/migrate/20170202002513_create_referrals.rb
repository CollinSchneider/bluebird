class CreateReferrals < ActiveRecord::Migration
  def change
    create_table :referrals do |t|
      t.references :user, index: true, foreign_key: true
      t.string :referred_email
      t.string :referral_code
      t.boolean :signed_up

      t.timestamps null: false
    end
  end
end
