class UpdateLiveEvents < ActiveRecord::Migration
  def up
		add_column :live_events, :menu_start_date, :date
		add_column :live_events, :menu_end_date, :date

		add_index :live_events, :menu_start_date
		add_index :live_events, :menu_end_date
  end

  def down
		remove_index :live_events, :menu_start_date
		remove_index :live_events, :menu_end_date

		remove_column :live_events, :menu_start_date, :date
		remove_column :live_events, :menu_end_date, :date
  end
end
