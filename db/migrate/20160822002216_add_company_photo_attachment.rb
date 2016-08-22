class AddCompanyPhotoAttachment < ActiveRecord::Migration
  def change
    add_attachment :company_photos, :logo
  end
end
