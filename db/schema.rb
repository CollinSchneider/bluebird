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

ActiveRecord::Schema.define(version: 20160521141723) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "batches", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.string   "duration"
    t.datetime "start_time"
    t.datetime "end_time"
    t.string   "status"
    t.string   "completed_status"
  end

  add_index "batches", ["user_id"], name: "index_batches_on_user_id", using: :btree

  create_table "commits", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "product_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "amount"
    t.string   "status"
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
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "user_id"
    t.integer  "batch_id"
    t.string   "discount"
    t.integer  "quantity"
    t.string   "status"
  end

  add_index "products", ["batch_id"], name: "index_products_on_batch_id", using: :btree
  add_index "products", ["user_id"], name: "index_products_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email"
    t.string   "password_digest"
    t.string   "user_type"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_foreign_key "batches", "users"
  add_foreign_key "commits", "products"
  add_foreign_key "commits", "users"
end
