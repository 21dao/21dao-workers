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

ActiveRecord::Schema.define(version: 2022_03_03_022440) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "arask_jobs", force: :cascade do |t|
    t.string "job"
    t.datetime "execute_at"
    t.string "interval"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["execute_at"], name: "index_arask_jobs_on_execute_at"
  end

  create_table "artists", force: :cascade do |t|
    t.string "name"
    t.string "twitter"
    t.text "bio"
    t.text "tags"
    t.string "exchange"
    t.string "holaplex"
    t.string "formfunction"
    t.text "images"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "auctions", force: :cascade do |t|
    t.bigint "start_time"
    t.bigint "end_time"
    t.bigint "reserve"
    t.bigint "min_increment"
    t.bigint "ending_phase"
    t.bigint "extension"
    t.bigint "highest_bid"
    t.integer "number_bids"
    t.string "auction_account"
    t.string "mint"
    t.string "brand_id"
    t.string "brand_name"
    t.string "collection_id"
    t.string "collection_name"
    t.string "image"
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "finalized", default: false
    t.string "highest_bidder"
    t.string "source"
    t.string "metadata_uri"
    t.string "highest_bidder_username"
    t.index ["auction_account"], name: "index_auctions_on_auction_account"
    t.index ["brand_id"], name: "index_auctions_on_brand_id"
    t.index ["brand_name"], name: "index_auctions_on_brand_name"
    t.index ["end_time"], name: "index_auctions_on_end_time"
    t.index ["start_time"], name: "index_auctions_on_start_time"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "listings", force: :cascade do |t|
    t.string "mint"
    t.boolean "is_listed"
    t.datetime "last_listed"
    t.string "listed_by"
    t.bigint "last_sale_price"
    t.bigint "last_listed_price"
    t.string "image"
    t.string "name"
    t.string "description"
    t.string "title"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_listings_on_name"
  end

  create_table "nfts", force: :cascade do |t|
    t.bigint "user_id"
    t.text "metadata"
    t.string "mint"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "visible", default: true
    t.integer "order_id"
    t.integer "edition"
    t.string "edition_name"
    t.integer "supply"
    t.integer "max_supply"
    t.index ["user_id"], name: "index_nfts_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.text "keys"
    t.string "api_key"
    t.string "nonce"
    t.boolean "loading", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "twitter"
    t.string "exchange"
    t.string "formfunction"
    t.string "holaplex"
    t.index ["keys"], name: "index_users_on_keys"
    t.index ["username"], name: "index_users_on_username"
  end

end
