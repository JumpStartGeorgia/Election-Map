class AddCustomViewRecords < ActiveRecord::Migration
  def up
		EventCustomView.destroy_all

		# add a custom view for each event so that at the country view, districts are visible
		I18n.locale = :en
		
		events = Event.all
		events.each do |event|
      # only create custom view if not tbilisi or adjara events
		  if event.name.index("Tbilisi").nil? && event.name.index("Adjara").nil?
			  EventCustomView.create(:event_id => event.id, :shape_type_id => 1, :descendant_shape_type_id => 3, :is_default_view => true)
			end
		end
  end

  def down
		EventCustomView.destroy_all
  end
end
