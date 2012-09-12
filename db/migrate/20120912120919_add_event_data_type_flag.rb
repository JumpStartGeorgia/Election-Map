class AddEventDataTypeFlag < ActiveRecord::Migration
  def up
		add_column :events, :has_official_data, :boolean, :default => false
		add_column :events, :has_live_data, :boolean, :default => false

		add_index :events, :has_official_data
		add_index :events, :has_live_data

		# indicate all events have official data
		Event.all.each do |event|
			event.has_official_data = true
			event.save
		end

  end

	def down
		remove_index :events, :has_official_data
		remove_index :events, :has_live_data

		remove_column :events, :has_official_data
		remove_column :events, :has_live_data


	end
end
