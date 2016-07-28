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

ActiveRecord::Schema.define(version: 20160727224756) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "commits", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "amount"
    t.string   "status"
    t.integer  "product_id"
    t.string   "shipping_id"
  end

  add_index "commits", ["product_id"], name: "index_commits_on_product_id", using: :btree
  add_index "commits", ["user_id"], name: "index_commits_on_user_id", using: :btree

  create_table "milestones", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "goal"
    t.integer  "product_id"
    t.integer  "batch_id"
  end

  add_index "milestones", ["batch_id"], name: "index_milestones_on_batch_id", using: :btree
  add_index "milestones", ["product_id"], name: "index_milestones_on_product_id", using: :btree

  create_table "products", force: :cascade do |t|
    t.string   "title"
    t.string   "price"
    t.string   "description"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.integer  "user_id"
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
  end

  add_index "products", ["user_id"], name: "index_products_on_user_id", using: :btree

  create_table "shipping_addresses", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "address_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "shipping_addresses", ["user_id"], name: "index_shipping_addresses_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email"
    t.string   "password_digest"
    t.string   "user_type"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.string   "retailer_stripe_id"
    t.string   "wholesaler_stripe_id"
  end

  add_foreign_key "commits", "users"
  add_foreign_key "shipping_addresses", "users"
end
