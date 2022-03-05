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

  create_table "__diesel_schema_migrations", primary_key: "version", id: { type: :string, limit: 50 }, force: :cascade do |t|
    t.datetime "run_on", default: -> { "CURRENT_TIMESTAMP" }, null: false
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

  create_table "editions", primary_key: "address", id: { type: :string, limit: 48 }, force: :cascade do |t|
    t.string "parent_address", limit: 48, null: false
    t.bigint "edition", null: false
  end

  create_table "listing_metadatas", primary_key: ["listing_address", "metadata_address"], force: :cascade do |t|
    t.string "listing_address", limit: 48, null: false
    t.string "metadata_address", limit: 48, null: false
    t.integer "metadata_index", null: false
    t.index ["listing_address"], name: "listing_metadatas_listing_address_idx"
  end

  create_table "listings", primary_key: "address", id: { type: :string, limit: 48 }, force: :cascade do |t|
    t.datetime "ends_at"
    t.datetime "created_at", null: false
    t.boolean "ended", null: false
    t.string "authority", limit: 48, null: false
    t.string "token_mint", limit: 48, null: false
    t.string "store_owner", limit: 48, null: false
    t.bigint "last_bid"
    t.datetime "end_auction_gap"
    t.bigint "price_floor"
    t.integer "total_uncancelled_bids"
    t.integer "gap_tick_size"
    t.bigint "instant_sale_price"
    t.text "name", null: false
  end

  create_table "master_editions", primary_key: "address", id: { type: :string, limit: 48 }, force: :cascade do |t|
    t.bigint "supply", null: false
    t.bigint "max_supply"
  end

  create_table "metadata_creators", primary_key: ["metadata_address", "creator_address"], force: :cascade do |t|
    t.string "metadata_address", limit: 48, null: false
    t.string "creator_address", limit: 48, null: false
    t.integer "share", null: false
    t.boolean "verified", default: false, null: false
    t.index ["metadata_address"], name: "metadata_creators_metadata_address_idx"
  end

  create_table "metadatas", primary_key: "address", id: { type: :string, limit: 48 }, force: :cascade do |t|
    t.text "name", null: false
    t.text "symbol", null: false
    t.text "uri", null: false
    t.integer "seller_fee_basis_points", null: false
    t.string "update_authority_address", limit: 48, null: false
    t.string "mint_address", limit: 48, null: false
    t.boolean "primary_sale_happened", default: false, null: false
    t.boolean "is_mutable", default: false, null: false
    t.integer "edition_nonce"
  end

  create_table "storefronts", primary_key: "owner_address", id: { type: :string, limit: 48 }, force: :cascade do |t|
    t.text "subdomain", null: false
    t.text "title", null: false
    t.text "description", null: false
    t.text "favicon_url", null: false
    t.text "logo_url", null: false
  end

  add_foreign_key "editions", "master_editions", column: "parent_address", primary_key: "address", name: "editions_parent_address_fkey"
  add_foreign_key "listing_metadatas", "listings", column: "listing_address", primary_key: "address", name: "listing_metadatas_listing_address_fkey"
  add_foreign_key "listing_metadatas", "metadatas", column: "metadata_address", primary_key: "address", name: "listing_metadatas_metadata_address_fkey"
  add_foreign_key "listings", "storefronts", column: "store_owner", primary_key: "owner_address", name: "listings_store_owner_fkey"
  add_foreign_key "metadata_creators", "metadatas", column: "metadata_address", primary_key: "address", name: "metadata_creators_metadata_address_fkey"
end
