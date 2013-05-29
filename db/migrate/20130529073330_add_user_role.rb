class AddUserRole < ActiveRecord::Migration
  def change
    add_column :users, :role, :integer, :default => 0

    # assign admin role to all existing users
    User.update_all(:role => 99)
  end
end
