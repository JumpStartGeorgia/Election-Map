class AddLiveMenuField < ActiveRecord::Migration
  def up
    add_column :menu_live_events, :data_available_at, :datetime
    add_index :menu_live_events, :data_available_at

		# add value to each exist live menu record
		MenuLiveEvent.all.each do |menu|
			# time is in utc -> geo is +4
			menu.data_available_at = '2012-10-01 21:00:00'
			menu.save
		end
  end

  def down
    remove_index :menu_live_events, :data_available_at
    remove_column :menu_live_events, :data_available_at
  end
end
