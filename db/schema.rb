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

ActiveRecord::Schema.define(version: 20171204111602) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "auctions", force: :cascade do |t|
    t.decimal "price_current", precision: 10, scale: 2, null: false
    t.decimal "price_limit", precision: 10, scale: 2, null: false
    t.integer "step_current", null: false
    t.integer "step_limit", null: false
    t.string "status", null: false
    t.datetime "ride_at", null: false
    t.datetime "start_at", null: false
    t.datetime "end_at", null: false
    t.bigint "driver_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["driver_id"], name: "index_auctions_on_driver_id"
    t.index ["start_at"], name: "index_auctions_on_start_at", unique: true
  end

  create_table "drivers", force: :cascade do |t|
    t.string "status", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "locks", force: :cascade do |t|
    t.string "entity", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["entity"], name: "index_locks_on_entity", unique: true
  end

end
