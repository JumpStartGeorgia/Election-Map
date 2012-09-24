class Create2012PartyIndRelationships < ActiveRecord::Migration
  def up
		events = [31,32]
	  total_turnout = 15

		events.each do |event_id|
		  # create custom view
		  # copy from 2008 record
		  custom = EventCustomView.where(:event_id => 3)
		  new_custom = EventCustomView.create(:event_id => event_id,
		    :shape_type_id => custom.first.shape_type_id,
		    :descendant_shape_type_id => custom.first.descendant_shape_type_id,
		    :is_default_view => custom.first.is_default_view)
		  en = custom.first.event_custom_view_translations.select{|x| x.locale == "en"}
		  new_custom.event_custom_view_translations.create(:locale => 'en', :note => en.first.note)
		  ka = custom.first.event_custom_view_translations.select{|x| x.locale == "ka"}
		  new_custom.event_custom_view_translations.create(:locale => 'ka', :note => ka.first.note)


			# copy the 2008 relationships for 'other' indicators and summary
			indicators = CoreIndicator.where(:indicator_type_id => 1)
		  relationships = EventIndicatorRelationship.where("event_id = 3 and (indicator_type_id = 2 or core_indicator_id in (?))", indicators.collect(&:id))
		  relationships.each do |r|
		    EventIndicatorRelationship.create(:event_id => event_id,
		      :indicator_type_id => r.indicator_type_id,
		      :core_indicator_id => r.core_indicator_id,
		      :related_core_indicator_id => r.related_core_indicator_id,
		      :sort_order => r.sort_order,
		      :related_indicator_type_id => r.related_indicator_type_id)
		  end


		  # create new relationships for the precincts reported indicators
			prec_num_core = CoreIndicatorTranslation.where("name = 'Precincts Reported (#)'")
		  prec_num = prec_num_core.first.core_indicator_id
			prec_perc_core = CoreIndicatorTranslation.where("name = 'Precincts Reported (%)'")
		  prec_perc = prec_perc_core.first.core_indicator_id

	    EventIndicatorRelationship.create(:event_id => event_id,
	      :core_indicator_id => prec_num,
	      :related_core_indicator_id => prec_num,
	      :sort_order => 1)
	    EventIndicatorRelationship.create(:event_id => event_id,
	      :core_indicator_id => prec_num,
	      :related_core_indicator_id => prec_perc,
	      :sort_order => 2)
	    EventIndicatorRelationship.create(:event_id => event_id,
	      :core_indicator_id => prec_num,
	      :related_core_indicator_id => total_turnout,
	      :sort_order => 3)

	    EventIndicatorRelationship.create(:event_id => event_id,
	      :core_indicator_id => prec_perc,
	      :related_core_indicator_id => prec_num,
	      :sort_order => 1)
	    EventIndicatorRelationship.create(:event_id => event_id,
	      :core_indicator_id => prec_perc,
	      :related_core_indicator_id => prec_perc,
	      :sort_order => 2)
	    EventIndicatorRelationship.create(:event_id => event_id,
	      :core_indicator_id => prec_perc,
	      :related_core_indicator_id => total_turnout,
	      :sort_order => 3)

			# create party relationships
			names = ['Free Georgia',
								'National Democratic Party of Georgia',
								'United National Movement',
								'Movement for Fair Georgia',
								'Christian-Democratic Movement',
								'Public Movement',
								'Freedom Party',
								'Georgian Group',
								'New Rights',
								'People\'s Party',
								'Merab Kostava Society',
								'Future Georgia',
								'Labour Council of Georgia',
								'Labour',
								'Sportsman\'s Union',
								'Georgian Dream']

			names.each do |name|
				# get core indicator
				trans = CoreIndicatorTranslation.where(:name => name)

			  EventIndicatorRelationship.create(:event_id => event_id,
			    :core_indicator_id => trans.first.core_indicator_id,
			    :related_core_indicator_id => trans.first.core_indicator_id,
			    :sort_order => 1)
			  EventIndicatorRelationship.create(:event_id => event_id,
			    :core_indicator_id => trans.first.core_indicator_id,
			    :related_core_indicator_id => total_turnout,
			    :sort_order => 2)
			end
		end


  end

  def down
		events = [31,32]
		events.each do |event_id|
		  EventIndicatorRelationship.where(:event_id => event_id).destroy_all
		  EventCustomView.where(:event_id => event_id).destroy_all
		end
  end
end
