class CreateReturnPolicies < ActiveRecord::Migration
  def change
    create_table :return_policies do |t|
      t.string :policy
      t.string :policy_key
      t.string :description

      t.timestamps null: false
    end
  end
end
