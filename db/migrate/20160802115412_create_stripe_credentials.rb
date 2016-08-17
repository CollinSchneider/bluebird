class CreateStripeCredentials < ActiveRecord::Migration
  def change
    create_table :stripe_credentials do |t|
      t.references :user, index: true, foreign_key: true
      t.string :stripe_publishable_key
      t.string :access_token

      t.timestamps null: false
    end
  end
end
