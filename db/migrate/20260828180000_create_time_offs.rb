class CreateTimeOffs < ActiveRecord::Migration[8.1]
  def change
    create_table :time_offs do |t|
      t.references :barber, null: false, foreign_key: { to_table: :users }
      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false
      t.string :reason
      t.timestamps
    end

    add_index :time_offs, [ :barber_id, :starts_at, :ends_at ]
    add_check_constraint :time_offs, "ends_at > starts_at", name: "time_offs_range_ordered"
  end
end
