class AddVpm < ActiveRecord::Migration
  def up
		# first fix ka for precinct vpms
		CoreIndicatorTranslation.where(:locale => 'ka', :core_indicator_id => [2,3,4,5,6]).each do |trans|
			trans.name = trans.description
			trans.save
		end

		old_ids = [7,8,9,10,11]
		new_ids = []

		# copy the existing non-precinct vpm indicators with time and switch to vpm>2
		CoreIndicator.where(:id => old_ids).order('id').each do |core|
			new_core = CoreIndicator.create(:indicator_type_id => core.indicator_type_id)
			new_ids << new_core.id
			en = core.core_indicator_translations.select{|x| x.locale == 'en'}
			new_core.core_indicator_translations.create(:locale => 'en',
				:name => en.first.name.gsub("> 3", "> 2"),
				:name_abbrv => en.first.name_abbrv.gsub("> 3", "> 2"),
				:description => en.first.description.gsub("> 3", "> 2")
			)
			ka = core.core_indicator_translations.select{|x| x.locale == 'ka'}
			new_core.core_indicator_translations.create(:locale => 'ka',
				:name => ka.first.name.gsub("> 3", "> 2"),
				:name_abbrv => ka.first.name_abbrv.gsub("> 3", "> 2"),
				:description => ka.first.description.gsub("> 3", "> 2")
			)
		end

		# copy the new vpm > 3 ind and switch to vpm>2
    trans = CoreIndicatorTranslation.where(:name => 'Number of Precincts with votes per minute > 3')
    core = CoreIndicator.find(trans.first.core_indicator_id)
		old_ids << core.id
		new_core = CoreIndicator.create(:indicator_type_id => core.indicator_type_id)
		new_ids << new_core.id
		en = core.core_indicator_translations.select{|x| x.locale == 'en'}
		new_core.core_indicator_translations.create(:locale => 'en',
			:name => en.first.name.gsub("> 3", "> 2"),
			:name_abbrv => en.first.name_abbrv.gsub("> 3", "> 2"),
			:description => en.first.description.gsub("> 3", "> 2")
		)
		ka = core.core_indicator_translations.select{|x| x.locale == 'ka'}
		new_core.core_indicator_translations.create(:locale => 'ka',
			:name => ka.first.name.gsub("> 3", "> 2"),
			:name_abbrv => ka.first.name_abbrv.gsub("> 3", "> 2"),
			:description => ka.first.description.gsub("> 3", "> 2")
		)

		# now update indicator relationship records for 2012 party list and major to use these new core ind
		[31,32].each do |event_id|
			old_ids.each_with_index do |old_id,i|
				EventIndicatorRelationship.where(:event_id => event_id, :core_indicator_id => old_id).each do |relationship|
					relationship.core_indicator_id = new_ids[i]
					relationship.save
				end
				EventIndicatorRelationship.where(:event_id => event_id, :related_core_indicator_id => old_id).each do |relationship|
					relationship.related_core_indicator_id = new_ids[i]
					relationship.save
				end
			end

			# delete all indicators for these events
			# - will reload by hand
			Indicator.where(:event_id => event_id).destroy_all
			DataSet.where(:event_id => event_id).destroy_all
		end


	end

  def down
		old_ids = [7,8,9,10,11]
    trans = CoreIndicatorTranslation.where(:name => 'Number of Precincts with votes per minute > 3')
		old_ids << trans.first.core_indicator_id

    trans = CoreIndicatorTranslation.where("name like '%> 2%'").order("core_indicator_id")

		# delete the relationships
		[31,32].each do |event_id|
			trans.collect(&:core_indicator_id).each_with_index do |new_id,i|
				EventIndicatorRelationship.where(:event_id => event_id, :core_indicator_id => new_id).each do |relationship|
					relationship.core_indicator_id = old_ids[i]
					relationship.save
				end
				EventIndicatorRelationship.where(:event_id => event_id, :related_core_indicator_id => new_id).each do |relationship|
					relationship.related_core_indicator_id = oold_ids[i]
					relationship.save
				end
			end
		end

		# delete the core indicators
		CoreIndicator.where(:id => trans.collect(&:core_indicator_id)).destroy_all

  end
end
