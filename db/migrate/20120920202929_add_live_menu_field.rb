class AddLiveMenuField < ActiveRecord::Migration
  def up
    add_column :menu_live_events, :data_available_at, :datetime
    add_index :menu_live_events, :data_available_at
  end

  def down
    remove_index :menu_live_events, :data_available_at
    remove_column :menu_live_events, :data_available_at
  end
end
