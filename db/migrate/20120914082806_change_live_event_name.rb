class ChangeLiveEventName < ActiveRecord::Migration
  def up
    remove_index :live_events, :event_id
		remove_index :live_events, :menu_start_date
		remove_index :live_events, :menu_end_date

		rename_table :live_events, :menu_live_events

    add_index :menu_live_events, :event_id
		add_index :menu_live_events, :menu_start_date
		add_index :menu_live_events, :menu_end_date
  end

  def down
    remove_index :menu_live_events, :event_id
		remove_index :menu_live_events, :menu_start_date
		remove_index :menu_live_events, :menu_end_date

		rename_table :menu_live_events, :live_events

    add_index :live_events, :event_id
		add_index :live_events, :menu_start_date
		add_index :live_events, :menu_end_date
  end
end
