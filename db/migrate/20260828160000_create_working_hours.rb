class CreateWorkingHours < ActiveRecord::Migration[8.1]
  def change
    create_table :working_hours do |t|
      t.integer :weekday, null: false
      t.time :opens_at, null: false
      t.time :closes_at, null: false
      t.integer :capacity, null: false, default: 2
      t.timestamps
    end

    add_index :working_hours, :weekday, unique: true
    add_check_constraint :working_hours, "weekday BETWEEN 0 AND 6", name: "working_hours_weekday_allowed"
    add_check_constraint :working_hours, "closes_at > opens_at", name: "working_hours_range_ordered"
    add_check_constraint :working_hours, "capacity > 0", name: "working_hours_capacity_positive"
  end
end
