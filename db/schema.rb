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

ActiveRecord::Schema.define(version: 20170203233553) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "admins", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "admins", ["user_id"], name: "index_admins_on_user_id", using: :btree

  create_table "commits", force: :cascade do |t|
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.integer  "amount"
    t.string   "status",                default: "live"
    t.integer  "product_id"
    t.string   "uuid"
    t.integer  "retailer_id"
    t.string   "card_id"
    t.boolean  "full_price",            default: false
    t.boolean  "refunded",              default: false
    t.integer  "shipping_address_id"
    t.boolean  "sale_made",             default: false
    t.integer  "wholesaler_id"
    t.boolean  "has_shipped",           default: false
    t.float    "sale_amount",           default: 0.0
    t.float    "shipping_amount"
    t.float    "sale_amount_with_fees", default: 0.0
    t.string   "number"
  end

  add_index "commits", ["product_id"], name: "index_commits_on_product_id", using: :btree

  create_table "companies", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "company_name"
    t.string   "company_key"
    t.string   "bio"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "location"
    t.string   "website"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.string   "uuid"
    t.string   "contact_email"
    t.integer  "contact_number",    limit: 8
  end

  add_index "companies", ["user_id"], name: "index_companies_on_user_id", using: :btree

  create_table "favorite_sellers", force: :cascade do |t|
    t.integer  "retailer_id"
    t.integer  "wholesaler_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "product_categories", force: :cascade do |t|
    t.string   "name"
    t.string   "key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "product_sizings", force: :cascade do |t|
    t.integer  "product_id"
    t.string   "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "product_sizings", ["product_id"], name: "index_product_sizings_on_product_id", using: :btree

  create_table "product_tokens", force: :cascade do |t|
    t.integer  "product_id"
    t.string   "token"
    t.datetime "expiration_datetime"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  add_index "product_tokens", ["product_id"], name: "index_product_tokens_on_product_id", using: :btree

  create_table "product_variants", force: :cascade do |t|
    t.integer  "product_id"
    t.string   "description"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
  end

  add_index "product_variants", ["product_id"], name: "index_product_variants_on_product_id", using: :btree

  create_table "products", force: :cascade do |t|
    t.string   "title"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
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
    t.string   "duration"
    t.datetime "start_time"
    t.datetime "end_time"
    t.string   "slug"
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
    t.float    "goal"
    t.float    "current_sales"
    t.boolean  "has_skus"
    t.string   "short_description"
    t.float    "percent_discount"
    t.float    "current_sales_with_fees"
    t.integer  "return_policy_id"
    t.string   "number"
  end

  create_table "purchase_orders", force: :cascade do |t|
    t.integer  "sku_id"
    t.integer  "commit_id"
    t.integer  "quantity"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.string   "shipping_id"
    t.boolean  "has_shipped",           default: false
    t.boolean  "sale_made",             default: false
    t.boolean  "refunded",              default: false
    t.boolean  "full_price",            default: false
    t.float    "sale_amount"
    t.float    "sale_amount_with_fees"
  end

  add_index "purchase_orders", ["commit_id"], name: "index_purchase_orders_on_commit_id", using: :btree
  add_index "purchase_orders", ["sku_id"], name: "index_purchase_orders_on_sku_id", using: :btree

  create_table "ratings", force: :cascade do |t|
    t.string   "comment"
    t.float    "rating"
    t.integer  "sale_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "referrals", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "referred_email"
    t.string   "referral_code"
    t.boolean  "signed_up"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "referrals", ["user_id"], name: "index_referrals_on_user_id", using: :btree

  create_table "retailers", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "stripe_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "retailers", ["user_id"], name: "index_retailers_on_user_id", using: :btree

  create_table "return_policies", force: :cascade do |t|
    t.string   "policy"
    t.string   "policy_key"
    t.string   "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "sales", force: :cascade do |t|
    t.integer  "commit_id"
    t.integer  "retailer_id"
    t.integer  "wholesaler_id"
    t.float    "sale_amount"
    t.string   "stripe_charge_id"
    t.boolean  "card_failed"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.string   "card_failed_reason"
    t.float    "charge_amount"
    t.datetime "card_failed_date"
    t.boolean  "has_rating",         default: false
    t.string   "number"
  end

  add_index "sales", ["commit_id"], name: "index_sales_on_commit_id", using: :btree
  add_index "sales", ["retailer_id"], name: "index_sales_on_retailer_id", using: :btree
  add_index "sales", ["wholesaler_id"], name: "index_sales_on_wholesaler_id", using: :btree

  create_table "shipping_addresses", force: :cascade do |t|
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.integer  "retailer_id"
    t.boolean  "primary"
    t.string   "street_address_one"
    t.string   "street_address_two"
    t.string   "city"
    t.string   "zip"
    t.string   "state"
  end

  create_table "shippings", force: :cascade do |t|
    t.integer  "retailer_id"
    t.integer  "wholesaler_id"
    t.float    "shipping_amount"
    t.string   "tracking_id"
    t.string   "stripe_charge_id"
    t.boolean  "card_failed"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.string   "card_failed_reason"
    t.datetime "card_failed_date"
    t.datetime "shipped_on"
    t.string   "number"
    t.string   "tracking_number"
    t.string   "carrier"
    t.string   "easypost_tracking_url"
  end

  add_index "shippings", ["retailer_id"], name: "index_shippings_on_retailer_id", using: :btree
  add_index "shippings", ["wholesaler_id"], name: "index_shippings_on_wholesaler_id", using: :btree

  create_table "skus", force: :cascade do |t|
    t.integer  "product_id"
    t.integer  "product_variant_id"
    t.integer  "product_sizing_id"
    t.float    "price"
    t.float    "discount_price"
    t.float    "suggested_retail"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.integer  "inventory"
    t.string   "code"
    t.float    "price_with_fee"
    t.string   "number"
  end

  add_index "skus", ["product_id"], name: "index_skus_on_product_id", using: :btree
  add_index "skus", ["product_sizing_id"], name: "index_skus_on_product_sizing_id", using: :btree
  add_index "skus", ["product_variant_id"], name: "index_skus_on_product_variant_id", using: :btree

  create_table "subscription_payments", force: :cascade do |t|
    t.integer  "wholesaler_id"
    t.boolean  "completed",      default: false
    t.string   "card_id"
    t.float    "charge_amount"
    t.datetime "due_at"
    t.boolean  "card_failed",    default: false
    t.datetime "card_failed_at"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "subscription_payments", ["wholesaler_id"], name: "index_subscription_payments_on_wholesaler_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email"
    t.string   "password_digest"
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.string   "first_name"
    t.string   "last_name"
    t.string   "phone_number"
    t.string   "password_reset_token"
    t.string   "password_reset_expiration"
    t.string   "uuid"
    t.boolean  "approved",                  default: false
  end

  create_table "wholesaler_stats", force: :cascade do |t|
    t.integer  "total_number_ratings",      default: 0
    t.integer  "total_rating",              default: 0
    t.integer  "total_shipping_difference", default: 0
    t.integer  "total_shipments",           default: 0
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  create_table "wholesalers", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "stripe_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.integer  "return_policy_id"
    t.integer  "wholesaler_stat_id"
    t.string   "shipping_policy"
    t.string   "stripe_customer_id"
  end

  add_index "wholesalers", ["user_id"], name: "index_wholesalers_on_user_id", using: :btree

  add_foreign_key "admins", "users"
  add_foreign_key "companies", "users"
  add_foreign_key "product_sizings", "products"
  add_foreign_key "product_tokens", "products"
  add_foreign_key "product_variants", "products"
  add_foreign_key "purchase_orders", "commits"
  add_foreign_key "purchase_orders", "skus"
  add_foreign_key "referrals", "users"
  add_foreign_key "retailers", "users"
  add_foreign_key "sales", "commits"
  add_foreign_key "sales", "retailers"
  add_foreign_key "sales", "wholesalers"
  add_foreign_key "shippings", "retailers"
  add_foreign_key "shippings", "wholesalers"
  add_foreign_key "skus", "product_sizings"
  add_foreign_key "skus", "product_variants"
  add_foreign_key "skus", "products"
  add_foreign_key "subscription_payments", "wholesalers"
  add_foreign_key "wholesalers", "users"
end
