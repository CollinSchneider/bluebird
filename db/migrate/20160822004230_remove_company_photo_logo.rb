class RemoveCompanyPhotoLogo < ActiveRecord::Migration
  def change
    drop_table :company_photos
    add_attachment :companies, :logo
  end
end
