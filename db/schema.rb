# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_08_29_063953) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "momo_box_sale_txes", force: :cascade do |t|
    t.integer "amount"
    t.datetime "crtime"
    t.string "order_id"
    t.bigint "price"
    t.string "tx"
    t.jsonb "payload"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["tx"], name: "index_momo_box_sale_txes_on_tx", unique: true
  end

  create_table "momo_listings", force: :cascade do |t|
    t.string "tx"
    t.string "token_id"
    t.bigint "start_price"
    t.bigint "now_price"
    t.bigint "end_price"
    t.integer "specialty"
    t.integer "quality"
    t.integer "lv_hashrate"
    t.integer "level"
    t.integer "index"
    t.string "raw_id"
    t.integer "hashrate"
    t.integer "duration_days"
    t.integer "category"
    t.string "auctor"
    t.integer "uptime"
    t.jsonb "payload"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["raw_id"], name: "index_momo_listings_on_raw_id", unique: true
  end

  create_table "price_alerts", force: :cascade do |t|
    t.string "coin"
    t.string "currency"
    t.float "price"
    t.float "last_price"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

end
