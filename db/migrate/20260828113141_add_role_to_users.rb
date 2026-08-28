class AddRoleToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :role, :string, null: false, default: "barber"

    add_check_constraint :users,
      "role IN ('barber', 'admin')",
      name: "users_role_allowed"
  end
end
