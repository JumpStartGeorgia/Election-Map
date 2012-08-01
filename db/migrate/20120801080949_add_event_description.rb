class AddEventDescription < ActiveRecord::Migration
  def up
		add_column :event_translations, :description, :text
	end

  def down
		remove_column :event_translations, :description
  end
end
