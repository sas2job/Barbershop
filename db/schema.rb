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

ActiveRecord::Schema[8.1].define(version: 2026_08_28_150000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "booking_slots", force: :cascade do |t|
    t.integer "capacity", default: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "starts_at", null: false
    t.datetime "updated_at", null: false
    t.index ["starts_at"], name: "index_booking_slots_on_starts_at", unique: true
    t.check_constraint "capacity > 0", name: "booking_slots_capacity_positive"
  end

  create_table "bookings", force: :cascade do |t|
    t.bigint "barber_id"
    t.bigint "booking_slot_id", null: false
    t.string "client_name", null: false
    t.datetime "created_at", null: false
    t.string "phone_number", null: false
    t.string "public_token", null: false
    t.bigint "service_id", null: false
    t.string "status", default: "confirmed", null: false
    t.datetime "updated_at", null: false
    t.index ["barber_id"], name: "index_bookings_on_barber_id"
    t.index ["booking_slot_id", "status"], name: "index_bookings_on_booking_slot_id_and_status"
    t.index ["booking_slot_id"], name: "index_bookings_on_booking_slot_id"
    t.index ["public_token"], name: "index_bookings_on_public_token", unique: true
    t.index ["service_id"], name: "index_bookings_on_service_id"
    t.check_constraint "status::text = ANY (ARRAY['confirmed'::character varying, 'cancelled'::character varying, 'annulled'::character varying]::text[])", name: "bookings_status_allowed"
  end

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
    t.check_constraint "category::text = ANY (ARRAY['women'::character varying::text, 'men'::character varying::text])", name: "services_category_allowed"
    t.check_constraint "duration_minutes > 0", name: "services_duration_positive"
    t.check_constraint "price_from_cents >= 0", name: "services_minimum_price_non_negative"
    t.check_constraint "price_to_cents >= price_from_cents", name: "services_price_range_ordered"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.string "role", default: "barber", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.check_constraint "role::text = ANY (ARRAY['barber'::character varying::text, 'admin'::character varying::text])", name: "users_role_allowed"
  end

  add_foreign_key "bookings", "booking_slots"
  add_foreign_key "bookings", "services"
  add_foreign_key "bookings", "users", column: "barber_id"
  add_foreign_key "sessions", "users"
end
