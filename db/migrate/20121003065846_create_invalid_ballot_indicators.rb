# encoding: utf-8
class CreateInvalidBallotIndicators < ActiveRecord::Migration
  def up
		total_turnout = 15
		event_ids = [31,32]
		core_ids = []

    # create core indicators
    puts "creating core inds"
		# 0-1%
    core = CoreIndicator.create(:indicator_type_id => 1)
    core.core_indicator_translations.create(:locale => 'en', :name => 'Number of Precincts with Invalid Ballots from 0-1%',
      :name_abbrv => 'Invalid Ballots 0-1%', :description => 'Number of Precincts with Invalid Ballots from 0-1%')
    core.core_indicator_translations.create(:locale => 'ka', :name => 'გაუქმებული საარჩევნო ბიულეტინი 0-1%',
      :name_abbrv => 'გაუქმებული საარჩევნო ბიულეტინი 0-1%', :description => 'გაუქმებული საარჩევნო ბიულეტინი 0-1%')
		core_ids << core.id
		# 1-3%
    core = CoreIndicator.create(:indicator_type_id => 1)
    core.core_indicator_translations.create(:locale => 'en', :name => 'Number of Precincts with Invalid Ballots from 1-3%',
      :name_abbrv => 'Invalid Ballots 1-3%', :description => 'Number of Precincts with Invalid Ballots from 1-3%')
    core.core_indicator_translations.create(:locale => 'ka', :name => 'გაუქმებული საარჩევნო ბიულეტინი 1-3%',
      :name_abbrv => 'გაუქმებული საარჩევნო ბიულეტინი 1-3%', :description => 'გაუქმებული საარჩევნო ბიულეტინი 1-3%')
		core_ids << core.id
		# 3-5%
    core = CoreIndicator.create(:indicator_type_id => 1)
    core.core_indicator_translations.create(:locale => 'en', :name => 'Number of Precincts with Invalid Ballots from 3-5%',
      :name_abbrv => 'Invalid Ballots 3-5%', :description => 'Number of Precincts with Invalid Ballots from 3-5%')
    core.core_indicator_translations.create(:locale => 'ka', :name => 'გაუქმებული საარჩევნო ბიულეტინი 3-5%',
      :name_abbrv => 'გაუქმებული საარჩევნო ბიულეტინი 3-5%', :description => 'გაუქმებული საარჩევნო ბიულეტინი 3-5%')
		core_ids << core.id
		# >5%
    core = CoreIndicator.create(:indicator_type_id => 1)
    core.core_indicator_translations.create(:locale => 'en', :name => 'Number of Precincts with Invalid Ballots > 5%',
      :name_abbrv => 'Invalid Ballots > 5%', :description => 'Number of Precincts with Invalid Ballots > 5%')
    core.core_indicator_translations.create(:locale => 'ka', :name => 'გაუქმებული საარჩევნო ბიულეტინი > 5%',
      :name_abbrv => 'გაუქმებული საარჩევნო ბიულეტინი > 5%', :description => 'გაუქმებული საარჩევნო ბიულეტინი > 5%')
		core_ids << core.id
		# invalid ballots % (precincts)
    core = CoreIndicator.create(:indicator_type_id => 1)
    core.core_indicator_translations.create(:locale => 'en', :name => 'Invalid Ballots (%)',
      :name_abbrv => 'Invalid Ballots (%)', :description => 'Invalid Ballots (%)')
    core.core_indicator_translations.create(:locale => 'ka', :name => 'გაუქმებული საარჩევნო ბიულეტინი (%)',
      :name_abbrv => 'გაუქმებული საარჩევნო ბიულეტინი (%)', :description => 'გაუქმებული საარჩევნო ბიულეტინი (%)')
		core_ids << core.id


    # create new relationships and indicator for each event
    event_ids.each do |event_id|
      puts "event #{event_id}"

      # create indicator relationships for non-precints for popup
			# 0-1, 1-3, 3-5, > 5, total turnout
      puts "- creating ind relationships for non-precincts"
      EventIndicatorRelationship.create(:event_id => event_id,
        :core_indicator_id => core_ids[3],
        :related_core_indicator_id => core_ids[0],
        :sort_order => 1)
      EventIndicatorRelationship.create(:event_id => event_id,
        :core_indicator_id => core_ids[3],
        :related_core_indicator_id => core_ids[1],
        :sort_order => 2)
      EventIndicatorRelationship.create(:event_id => event_id,
        :core_indicator_id => core_ids[3],
        :related_core_indicator_id => core_ids[2],
        :sort_order => 3)
      EventIndicatorRelationship.create(:event_id => event_id,
				:has_openlayers_rule_value => true,
        :core_indicator_id => core_ids[3],
        :related_core_indicator_id => core_ids[3],
        :sort_order => 4)
      EventIndicatorRelationship.create(:event_id => event_id,
        :core_indicator_id => core_ids[3],
        :related_core_indicator_id => total_turnout,
        :sort_order => 5)

      # create indicator relationships for precints for popup
			# invalid ballots, total turnout
      puts "- creating ind relationships for precincts"
      EventIndicatorRelationship.create(:event_id => event_id,
				:has_openlayers_rule_value => true,
        :core_indicator_id => core_ids[4],
        :related_core_indicator_id => core_ids[4],
        :sort_order => 1)
      EventIndicatorRelationship.create(:event_id => event_id,
        :core_indicator_id => core_ids[4],
        :related_core_indicator_id => total_turnout,
        :sort_order => 2)


			# create indicators
			puts "- create indicators"
			shape_type_ids = [1,2,3,4,7,8]
			shape_type_precincts = [4,8]
			new_indicators = []
			shape_type_ids.each do |shape_type_id|
				puts "-- shape type = #{shape_type_id}"

				core_ids.each_with_index do |core_id, index|
					# create correct indicators at appropriate shape levels
					if (index < 4 && shape_type_precincts.index(shape_type_id).nil?) ||
						(index == 4 && !shape_type_precincts.index(shape_type_id).nil?)

						puts "--- core id #{core_id} (index #{index})"
						indicator = Indicator.new()
						indicator.event_id = event_id
						indicator.shape_type_id = shape_type_id
						indicator.core_indicator_id = core_id
						if index == 3 && shape_type_precincts.index(shape_type_id).nil?
							indicator.visible = true
						elsif index == 4 && !shape_type_precincts.index(shape_type_id).nil?
							indicator.visible = true
						else
							indicator.visible = false
						end

		        # if this is not root, add ancestry value
		        if indicator.shape_type_id != 1
							temp_core_ind = nil
							if shape_type_precincts.index(shape_type_id).nil?
								temp_core_ind = indicator.core_indicator_id
							else
								# this is a precinct, so parent is using other core ind id
								temp_core_ind = core_ids[3]
							end

		          parent_indicator = new_indicators.select{|x| x.shape_type_id == indicator.shape_type.parent_id &&
		              x.core_indicator_id == temp_core_ind}.first

		          if parent_indicator
		            indicator.parent_id = parent_indicator.id
		          end
		        end

		        indicator.save

						# save the new indicator so can quickly get ancestry value
						new_indicators << indicator

						# - only need scales for >5% at non-precincts and for invalid ballots(%) at precincts
						if index == 3 && shape_type_precincts.index(shape_type_id).nil?
							puts "--- adding scales"
							# non-precinct scales
							if shape_type_id == 1
								# 0-100
								scale = IndicatorScale.create(:indicator_id => indicator.id)
								scale.indicator_scale_translations.create(:locale => 'en', :name => '0-100')
								scale.indicator_scale_translations.create(:locale => 'ka', :name => '0-100')
								# 100-200
								scale = IndicatorScale.create(:indicator_id => indicator.id)
								scale.indicator_scale_translations.create(:locale => 'en', :name => '100-200')
								scale.indicator_scale_translations.create(:locale => 'ka', :name => '100-200')
								# 200-300
								scale = IndicatorScale.create(:indicator_id => indicator.id)
								scale.indicator_scale_translations.create(:locale => 'en', :name => '200-300')
								scale.indicator_scale_translations.create(:locale => 'ka', :name => '200-300')
								# 300-400
								scale = IndicatorScale.create(:indicator_id => indicator.id)
								scale.indicator_scale_translations.create(:locale => 'en', :name => '300-400')
								scale.indicator_scale_translations.create(:locale => 'ka', :name => '300-400')
								# 400-500
								scale = IndicatorScale.create(:indicator_id => indicator.id)
								scale.indicator_scale_translations.create(:locale => 'en', :name => '400-500')
								scale.indicator_scale_translations.create(:locale => 'ka', :name => '400-500')
								# > 500
								scale = IndicatorScale.create(:indicator_id => indicator.id)
								scale.indicator_scale_translations.create(:locale => 'en', :name => '>500')
								scale.indicator_scale_translations.create(:locale => 'ka', :name => '>500')

							elsif shape_type_id == 2
								# 0-10
								scale = IndicatorScale.create(:indicator_id => indicator.id)
								scale.indicator_scale_translations.create(:locale => 'en', :name => '0-10')
								scale.indicator_scale_translations.create(:locale => 'ka', :name => '0-10')
								# 10-20
								scale = IndicatorScale.create(:indicator_id => indicator.id)
								scale.indicator_scale_translations.create(:locale => 'en', :name => '10-20')
								scale.indicator_scale_translations.create(:locale => 'ka', :name => '10-20')
								# 20-30
								scale = IndicatorScale.create(:indicator_id => indicator.id)
								scale.indicator_scale_translations.create(:locale => 'en', :name => '20-30')
								scale.indicator_scale_translations.create(:locale => 'ka', :name => '20-30')
								# 30-40
								scale = IndicatorScale.create(:indicator_id => indicator.id)
								scale.indicator_scale_translations.create(:locale => 'en', :name => '30-40')
								scale.indicator_scale_translations.create(:locale => 'ka', :name => '30-40')
								# 40-50
								scale = IndicatorScale.create(:indicator_id => indicator.id)
								scale.indicator_scale_translations.create(:locale => 'en', :name => '40-50')
								scale.indicator_scale_translations.create(:locale => 'ka', :name => '40-50')
								# > 50
								scale = IndicatorScale.create(:indicator_id => indicator.id)
								scale.indicator_scale_translations.create(:locale => 'en', :name => '>50')
								scale.indicator_scale_translations.create(:locale => 'ka', :name => '>50')

							elsif shape_type_id == 3 || shape_type_id == 7
								# 0-2
								scale = IndicatorScale.create(:indicator_id => indicator.id)
								scale.indicator_scale_translations.create(:locale => 'en', :name => '0-2')
								scale.indicator_scale_translations.create(:locale => 'ka', :name => '0-2')
								# 2-4
								scale = IndicatorScale.create(:indicator_id => indicator.id)
								scale.indicator_scale_translations.create(:locale => 'en', :name => '2-4')
								scale.indicator_scale_translations.create(:locale => 'ka', :name => '2-4')
								# 4-6
								scale = IndicatorScale.create(:indicator_id => indicator.id)
								scale.indicator_scale_translations.create(:locale => 'en', :name => '4-6')
								scale.indicator_scale_translations.create(:locale => 'ka', :name => '4-6')
								# 6-8
								scale = IndicatorScale.create(:indicator_id => indicator.id)
								scale.indicator_scale_translations.create(:locale => 'en', :name => '6-8')
								scale.indicator_scale_translations.create(:locale => 'ka', :name => '6-8')
								# 8-10
								scale = IndicatorScale.create(:indicator_id => indicator.id)
								scale.indicator_scale_translations.create(:locale => 'en', :name => '8-10')
								scale.indicator_scale_translations.create(:locale => 'ka', :name => '8-10')
								# > 10
								scale = IndicatorScale.create(:indicator_id => indicator.id)
								scale.indicator_scale_translations.create(:locale => 'en', :name => '>10')
								scale.indicator_scale_translations.create(:locale => 'ka', :name => '>10')

							end

						elsif index == 4 && !shape_type_precincts.index(shape_type_id).nil?
							puts "--- adding scales"
							# precinct scales
							# 0-2
							scale = IndicatorScale.create(:indicator_id => indicator.id)
							scale.indicator_scale_translations.create(:locale => 'en', :name => '0-2')
							scale.indicator_scale_translations.create(:locale => 'ka', :name => '0-2')
							# 2-4
							scale = IndicatorScale.create(:indicator_id => indicator.id)
							scale.indicator_scale_translations.create(:locale => 'en', :name => '2-4')
							scale.indicator_scale_translations.create(:locale => 'ka', :name => '2-4')
							# 4-6
							scale = IndicatorScale.create(:indicator_id => indicator.id)
							scale.indicator_scale_translations.create(:locale => 'en', :name => '4-6')
							scale.indicator_scale_translations.create(:locale => 'ka', :name => '4-6')
							# 6-8
							scale = IndicatorScale.create(:indicator_id => indicator.id)
							scale.indicator_scale_translations.create(:locale => 'en', :name => '6-8')
							scale.indicator_scale_translations.create(:locale => 'ka', :name => '6-8')
							# 8-10
							scale = IndicatorScale.create(:indicator_id => indicator.id)
							scale.indicator_scale_translations.create(:locale => 'en', :name => '8-10')
							scale.indicator_scale_translations.create(:locale => 'ka', :name => '8-10')
							# > 10
							scale = IndicatorScale.create(:indicator_id => indicator.id)
							scale.indicator_scale_translations.create(:locale => 'en', :name => '>10')
							scale.indicator_scale_translations.create(:locale => 'ka', :name => '>10')
						end
					end
				end
			end
		end
  end

  def down
		# delete core indicators
		trans = CoreIndicatorTranslation.where("name like '%invalid ballot%'")
		if trans && !trans.empty?
			CoreIndicator.where(:id => trans.collect(&:core_indicator_id)).destroy_all
		end
	end
end
