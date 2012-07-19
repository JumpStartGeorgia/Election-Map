# encoding: utf-8

class SplitEvents < ActiveRecord::Migration
  def up

		# add the sort column
		add_column :event_types, :sort_order, :integer, :default => 1
		add_index :event_types, :sort_order

		# change the current 'event' type to presidential
		ets = EventTypeTranslation.where(:event_type_id => 1)
		ets.each do |et|
			if et.locale == 'en'
				et.name = 'Presidential'
			elsif et.locale == 'ka'
				et.name = 'მდგომარეობით'
			end
			et.save
		end

		#update sort order for voter list
		et = EventType.find(2)
		et.sort_order = 5
		et.save

		# add the new event types
		et = EventType.create(:id => 3, :sort_order => 2)
		et.event_type_translations.create(:name=>"საპარლამენტო", :locale=>"ka")
		et.event_type_translations.create(:name => "Parliamentary", :locale=>"en")
		et = EventType.create(:id => 4, :sort_order => 3)
		et.event_type_translations.create(:name=>"აჭარის", :locale=>"ka")
		et.event_type_translations.create(:name => "Adjara SC", :locale=>"en")
		et = EventType.create(:id => 5, :sort_order => 4)
		et.event_type_translations.create(:name=>"ადგილობრივი", :locale=>"ka")
		et.event_type_translations.create(:name => "Local", :locale=>"en")

		# clear cache
		Rails.cache.clear
  end

  def down
		EventType.unscoped.destroy_all("id in (3,4,5)")

		remove_index :event_types, :sort_order
		remove_column :event_types, :sort_order
  end
end
