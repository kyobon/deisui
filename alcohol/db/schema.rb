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

ActiveRecord::Schema[7.1].define(version: 2024_11_28_154137) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "records", force: :cascade do |t|
    t.integer "beer"
    t.integer "highball"
    t.integer "chuhi"
    t.integer "sake"
    t.integer "wine"
    t.integer "whiskey"
    t.integer "shochu"
    t.boolean "heavy_drinking"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "drink_day"
    t.integer "hours"
    t.integer "minutes"
    t.string "user_id", null: false
    t.string "drunk"
    t.float "toughness"
    t.index ["user_id", "created_at"], name: "index_records_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_records_on_user_id"
  end

  create_table "users", id: :string, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.string "remember_digest"
    t.boolean "admin", default: false
    t.string "activation_digest"
    t.boolean "activated", default: false
    t.datetime "activated_at"
    t.string "reset_digest"
    t.datetime "reset_sent_at"
  end

  add_foreign_key "records", "users"
end
