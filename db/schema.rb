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

ActiveRecord::Schema.define(version: 20190119114832) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "customers", force: :cascade do |t|
    t.string   "title",             limit: 50
    t.string   "first_name",        limit: 200
    t.string   "middle_name",       limit: 200
    t.string   "last_name",         limit: 200
    t.string   "suffix",            limit: 50
    t.string   "display_name",      limit: 200
    t.string   "email",             limit: 200
    t.string   "company_name",      limit: 200
    t.string   "phone",             limit: 20
    t.string   "mobile",            limit: 20
    t.string   "notes",             limit: 255
    t.string   "address1",          limit: 200
    t.string   "city",              limit: 50
    t.string   "state",             limit: 50
    t.string   "country",           limit: 50
    t.string   "postal_code",       limit: 6
    t.boolean  "status",                        default: true
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.integer  "qbo_id"
    t.integer  "user_id"
    t.integer  "payment_method_id"
  end

  create_table "deposits", force: :cascade do |t|
    t.string   "name"
    t.integer  "user_id"
    t.integer  "qbo_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "items", force: :cascade do |t|
    t.integer  "qbo_id"
    t.string   "name",       limit: 200
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "user_id"
  end

  create_table "payment_methods", force: :cascade do |t|
    t.string   "name",       limit: 200
    t.integer  "user_id"
    t.integer  "qbo_id"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "sales_receipt_details", force: :cascade do |t|
    t.integer  "sales_receipt_id"
    t.string   "product_name",        limit: 200
    t.string   "product_description", limit: 200
    t.integer  "qty"
    t.integer  "rate"
    t.integer  "amt"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.integer  "item_id"
    t.integer  "tax_code_id"
    t.integer  "user_id"
  end

  create_table "sales_receipts", force: :cascade do |t|
    t.integer  "customer_id"
    t.string   "email",             limit: 200
    t.jsonb    "billing_address"
    t.datetime "receipt_date"
    t.string   "place_of_supply",   limit: 100
    t.string   "payment_method",    limit: 100
    t.string   "reference_no",      limit: 100
    t.string   "deposit_to",        limit: 100
    t.string   "message",           limit: 200
    t.integer  "total_qty"
    t.integer  "total_amt"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.integer  "qb_receipt_id"
    t.integer  "payment_method_id"
    t.integer  "deposit_to_id"
    t.integer  "user_id"
  end

  create_table "tax_codes", force: :cascade do |t|
    t.string   "name",       limit: 200
    t.integer  "user_id"
    t.integer  "qbo_id"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "prefix",             limit: 6
    t.string   "first_name",         limit: 200
    t.string   "last_name",          limit: 200
    t.integer  "age"
    t.integer  "sex"
    t.string   "mobile",             limit: 20
    t.string   "email",              limit: 200
    t.string   "password"
    t.integer  "role_id"
    t.string   "created_by"
    t.string   "updated_by"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.text     "qb_token"
    t.text     "secret"
    t.string   "realm_id"
    t.string   "code"
    t.string   "state"
    t.datetime "token_generated_at"
    t.text     "refresh_token"
  end

end
