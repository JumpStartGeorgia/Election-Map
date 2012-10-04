class AddDefaultViewFlagToEvents < ActiveRecord::Migration
  def up

		add_column :events, :is_default_view, :boolean, :default => false

		# make 2012 parl party list default
		event = Event.find(31)
		event.is_default_view = true
		event.save
  end

	def down
		remove_column :events, :is_default_view
	end
end
