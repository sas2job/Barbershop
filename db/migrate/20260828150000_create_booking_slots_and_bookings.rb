class CreateBookingSlotsAndBookings < ActiveRecord::Migration[8.1]
  def change
    create_table :booking_slots do |t|
      t.datetime :starts_at, null: false
      t.integer :capacity, null: false, default: 2
      t.timestamps
    end

    add_index :booking_slots, :starts_at, unique: true
    add_check_constraint :booking_slots, "capacity > 0", name: "booking_slots_capacity_positive"

    create_table :bookings do |t|
      t.references :service, null: false, foreign_key: true
      t.references :booking_slot, null: false, foreign_key: true
      t.string :client_name, null: false
      t.string :phone_number, null: false
      t.string :public_token, null: false
      t.string :status, null: false, default: "confirmed"
      t.references :barber, foreign_key: { to_table: :users }
      t.timestamps
    end

    add_index :bookings, :public_token, unique: true
    add_index :bookings, [ :booking_slot_id, :status ]
    add_check_constraint :bookings, "status IN ('confirmed', 'cancelled', 'annulled')", name: "bookings_status_allowed"
  end
end
