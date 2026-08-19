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

ActiveRecord::Schema[8.1].define(version: 2026_08_19_190000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "services", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "category", null: false
    t.datetime "created_at", null: false
    t.integer "duration_minutes", null: false
    t.string "name", null: false
    t.integer "price_from_cents", null: false
    t.integer "price_to_cents", null: false
    t.datetime "updated_at", null: false
    t.index ["category", "active"], name: "index_services_on_category_and_active"
    t.check_constraint "category::text = ANY (ARRAY['women'::character varying, 'men'::character varying]::text[])", name: "services_category_allowed"
    t.check_constraint "duration_minutes > 0", name: "services_duration_positive"
    t.check_constraint "price_from_cents >= 0", name: "services_minimum_price_non_negative"
    t.check_constraint "price_to_cents >= price_from_cents", name: "services_price_range_ordered"
  end
end
