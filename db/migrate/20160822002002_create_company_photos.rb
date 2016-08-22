class CreateCompanyPhotos < ActiveRecord::Migration
  def change
    create_table :company_photos do |t|
      t.references :company, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
