class CreateBarberWorkingHours < ActiveRecord::Migration[8.1]
  def change
    create_table :barber_working_hours do |t|
      t.references :barber, null: false, foreign_key: { to_table: :users }
      t.integer :weekday, null: false
      t.time :opens_at, null: false
      t.time :closes_at, null: false
      t.timestamps
    end

    add_index :barber_working_hours, %i[barber_id weekday], unique: true
    add_check_constraint :barber_working_hours, "weekday BETWEEN 0 AND 6", name: "barber_working_hours_weekday_allowed"
    add_check_constraint :barber_working_hours, "closes_at > opens_at", name: "barber_working_hours_range_ordered"
  end
end
