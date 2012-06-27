class AddCustomViewRecords < ActiveRecord::Migration
  def up
		EventCustomView.destroy_all

		# add a custom view for each event so that at the country view, districts are visible
		events = Event.all
		events.each do |event|
			EventCustomView.create(:event_id => event.id, :shape_type_id => 1, :descendant_shape_type_id => 3, :is_default_view => true)
		end
  end

  def down
		EventCustomView.destroy_all
  end
end
