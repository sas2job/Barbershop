class CreateServices < ActiveRecord::Migration[8.1]
  def change
    create_table :services do |t|
      t.string :name, null: false
      t.string :category, null: false
      t.integer :duration_minutes, null: false
      t.integer :price_from_cents, null: false
      t.integer :price_to_cents, null: false
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :services, [ :category, :active ]

    add_check_constraint :services,
      "category IN ('women', 'men')",
      name: "services_category_allowed"
    add_check_constraint :services,
      "duration_minutes > 0",
      name: "services_duration_positive"
    add_check_constraint :services,
      "price_from_cents >= 0",
      name: "services_minimum_price_non_negative"
    add_check_constraint :services,
      "price_to_cents >= price_from_cents",
      name: "services_price_range_ordered"
  end
end
