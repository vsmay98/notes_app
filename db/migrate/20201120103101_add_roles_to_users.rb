class AddRolesToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :admin_role, :boolean, default: false
  end
end
