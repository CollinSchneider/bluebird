# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160826224543) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "admins", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "admins", ["user_id"], name: "index_admins_on_user_id", using: :btree

  create_table "commits", force: :cascade do |t|
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.integer  "amount"
    t.string   "status"
    t.integer  "product_id"
    t.string   "shipping_id"
    t.string   "stripe_charge_id"
    t.string   "sale_amount"
    t.boolean  "pdf_generated"
    t.string   "uuid"
    t.integer  "retailer_id"
    t.boolean  "card_declined"
    t.datetime "card_decline_date"
    t.string   "card_id"
    t.string   "declined_reason"
    t.boolean  "full_price"
    t.boolean  "refunded"
    t.string   "shipping_charge_id"
  end

  add_index "commits", ["product_id"], name: "index_commits_on_product_id", using: :btree

  create_table "companies", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "company_name"
    t.string   "company_key"
    t.string   "bio"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.string   "location"
    t.string   "website"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
  end

  add_index "companies", ["user_id"], name: "index_companies_on_user_id", using: :btree

  create_table "full_price_commits", force: :cascade do |t|
    t.integer  "product_id"
    t.integer  "retailer_id"
    t.string   "uuid"
    t.integer  "amount"
    t.string   "stripe_charge_id"
    t.boolean  "card_declined"
    t.datetime "card_decline_date"
    t.string   "declined_reason"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.string   "card_id"
    t.string   "shipping_id"
  end

  add_index "full_price_commits", ["product_id"], name: "index_full_price_commits_on_product_id", using: :btree
  add_index "full_price_commits", ["retailer_id"], name: "index_full_price_commits_on_retailer_id", using: :btree

  create_table "milestones", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "goal"
    t.integer  "product_id"
    t.integer  "batch_id"
  end

  add_index "milestones", ["batch_id"], name: "index_milestones_on_batch_id", using: :btree
  add_index "milestones", ["product_id"], name: "index_milestones_on_product_id", using: :btree

  create_table "product_features", force: :cascade do |t|
    t.integer  "product_id"
    t.string   "feature"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "product_features", ["product_id"], name: "index_product_features_on_product_id", using: :btree

  create_table "product_images", force: :cascade do |t|
    t.integer  "product_id"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_index "product_images", ["product_id"], name: "index_product_images_on_product_id", using: :btree

  create_table "product_tokens", force: :cascade do |t|
    t.integer  "product_id"
    t.string   "token"
    t.datetime "expiration_datetime"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  add_index "product_tokens", ["product_id"], name: "index_product_tokens_on_product_id", using: :btree

  create_table "products", force: :cascade do |t|
    t.string   "title"
    t.string   "price"
    t.string   "description"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.string   "discount"
    t.string   "status"
    t.string   "category"
    t.string   "main_image_file_name"
    t.string   "main_image_content_type"
    t.integer  "main_image_file_size"
    t.datetime "main_image_updated_at"
    t.string   "photo_two_file_name"
    t.string   "photo_two_content_type"
    t.integer  "photo_two_file_size"
    t.datetime "photo_two_updated_at"
    t.string   "photo_three_file_name"
    t.string   "photo_three_content_type"
    t.integer  "photo_three_file_size"
    t.datetime "photo_three_updated_at"
    t.string   "photo_four_file_name"
    t.string   "photo_four_content_type"
    t.integer  "photo_four_file_size"
    t.datetime "photo_four_updated_at"
    t.string   "photo_five_file_name"
    t.string   "photo_five_content_type"
    t.integer  "photo_five_file_size"
    t.datetime "photo_five_updated_at"
    t.integer  "quantity"
    t.string   "duration"
    t.datetime "start_time"
    t.datetime "end_time"
    t.string   "slug"
    t.string   "goal"
    t.string   "current_sales"
    t.string   "percent_discount"
    t.boolean  "featured",                 default: false
    t.string   "uuid"
    t.integer  "wholesaler_id"
    t.string   "long_description"
    t.string   "feature_one"
    t.string   "feature_two"
    t.string   "feature_three"
    t.string   "feature_four"
    t.string   "feature_five"
    t.integer  "minimum_order"
  end

  create_table "retailers", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "stripe_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "retailers", ["user_id"], name: "index_retailers_on_user_id", using: :btree

  create_table "shipping_addresses", force: :cascade do |t|
    t.string   "address_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "retailer_id"
    t.boolean  "primary"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email"
    t.string   "password_digest"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.string   "first_name"
    t.string   "last_name"
    t.string   "phone_number"
    t.string   "password_reset_token"
    t.string   "password_reset_expiration"
    t.string   "uuid"
  end

  create_table "wholesalers", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "stripe_id"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.boolean  "approved"
    t.boolean  "contactable_by_phone"
    t.boolean  "contactable_by_email"
  end

  add_index "wholesalers", ["user_id"], name: "index_wholesalers_on_user_id", using: :btree

  add_foreign_key "admins", "users"
  add_foreign_key "companies", "users"
  add_foreign_key "full_price_commits", "products"
  add_foreign_key "full_price_commits", "retailers"
  add_foreign_key "product_features", "products"
  add_foreign_key "product_images", "products"
  add_foreign_key "product_tokens", "products"
  add_foreign_key "retailers", "users"
  add_foreign_key "wholesalers", "users"
end
