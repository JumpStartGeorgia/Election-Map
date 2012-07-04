module BuildCache

  def self.run
    # turn off the active record logging
    old_logger = ActiveRecord::Base.logger
    ActiveRecord::Base.logger = nil

		# clear the cache
		Rails.cache.clear
    
    # create new instance of app
    app = ActionDispatch::Integration::Session.new(Rails.application)

		start = Time.now
		puts "============ starting build cache at #{start}"
		# get the events that have shapes assigned to them
		# if no shape assigned, then not appearing on site
		events = Event.where("shape_id is not null")
#		events = Event.where("id between 1 and 4")
		if !events.nil? && !events.empty?
			events.each_with_index do |event, i|
				event_start = Time.now
				shape_type_id = event.shape.shape_type_id
				# see if event has custom view
				custom_view = event.event_custom_views.where(:shape_type_id => shape_type_id)

        is_custom_view = false
				if !custom_view.nil? && !custom_view.empty? && custom_view.first.is_default_view
					# has custom view, use the custom shape type
					shape_type_id = custom_view.first.descendant_shape_type_id
					is_custom_view = true
				end

				indicator_types = IndicatorType.find_by_event_shape_type(event.id, shape_type_id)
				if !indicator_types.nil? && !indicator_types.empty?
					# if the first indicator type has a summary, load summary data
					# else, load data for first indicator
					if indicator_types[0].has_summary
						I18n.available_locales.each do |locale|
							# load the parent shape
#							app.get "/#{locale}/json/shape/#{event.shape_id}"

							# load the children shapes
							if is_custom_view
							  app.get "/#{locale}/json/summary_grandchildren_shapes/#{event.shape_id}/event/#{event.id}/indicator_type/#{indicator_types[0].id}"
							else
							  app.get "/#{locale}/json/summary_children_shapes/#{event.shape_id}/event/#{event.id}/indicator_type/#{indicator_types[0].id}"
						  end
						end
					elsif !indicator_types[0].core_indicators.nil? && !indicator_types[0].core_indicators.empty? &&
								!indicator_types[0].core_indicators[0].indicators.nil? && !indicator_types[0].core_indicators[0].indicators.empty?
						I18n.available_locales.each do |locale|
							# load the parent shape
#							app.get "/#{locale}/json/shape/#{event.shape_id}"

							# load the children shapes
							if is_custom_view
							  app.get "/#{locale}/json/grandchildren_shapes/#{event.shape_id}/indicator/#{indicator_types[0].core_indicators[0].indicators[0].id}"
							else
							  app.get "/#{locale}/json/children_shapes/#{event.shape_id}/parent_clickable/false/indicator/#{indicator_types[0].core_indicators[0].indicators[0].id}"
						  end
						end
					end
					puts "=================== "				
					puts "=================== time to load event #{event.id} was #{(Time.now-event_start)} seconds"				
					puts "=================== "				
				end
			end
		end

		end_time = Time.now

    # turn active record logging back on
    ActiveRecord::Base.logger = old_logger

		puts "============ total time took #{(end_time - start)} seconds"
  end

	def self.run_test
		# clear the cache
		Rails.cache.clear
		count = 0

		start = Time.now

		# cache all shapes
		shapes = Shape.where("ancestry is null")

		shapes.each do |shape|
			app.get "/en/grandchildren_shapes/#{shape.id}"
			count += shape.children.count
			shape.children.each do |child|
				app.get "/en/grandchildren_shapes/#{child.id}"
			end
		end

		end_time_shapes = Time.now

		# cache all shapes for each event and for each indicator
		events = Event.all

		events.each do |event|
			if !event.shape_id.nil?
				# get event shape
				shape = Shape.find(event.shape_id)
				
				# get indicators for event at the district and precinct level
				indicators_country = Indicator.where(["event_id = ? and shape_type_id = 1", event.id])				
				indicators_region = Indicator.where(["event_id = ? and shape_type_id = 2", event.id])				
				indicators_district = Indicator.where(["event_id = ? and shape_type_id = 3", event.id])				
				indicators_precinct = Indicator.where(["event_id = ? and shape_type_id = 4", event.id])				

				# country indicators
				if !indicators_country.nil? && !indicators_country.empty?
					indicators_country.each do |ind|
						# get shapes for each indicator
#						app.get "/en/children_shapes/#{shape.id}/parent_clickable/true/indicator/#{ind.id}"
					end
				end


				# region indicators
				if !indicators_region.nil? && !indicators_region.empty?
					indicators_region.each do |ind|
						# get shapes for each indicator
#						app.get "/en/children_shapes/#{shape.id}/parent_clickable/false/indicator/#{ind.id}"
					end
				end

				# district indicators
				if !indicators_district.nil? && !indicators_district.empty?
					indicators_district.each do |ind|
						# get shapes for each indicator
#						app.get "/en/children_shapes/#{shape.id}/parent_clickable/false/indicator/#{ind.id}"
						app.get "/en/grandchildren_shapes/#{shape.id}/indicator/#{ind.id}"
					end
				end

			  # precinct indicators
				if !indicators_precinct.nil? && !indicators_precinct.empty?
					indicators_precinct.each do |ind|
						shape.children.each do |child|
							# get shapes for each indicator
#							app.get "/en/children_shapes/#{child.id}/parent_clickable/false/indicator/#{ind.id}"
							app.get "/en/grandchildren_shapes/#{child.id}/indicator/#{ind.id}"
						end
					end
				end
			end
		end

		end_time = Time.now

		puts "end time = #{end_time}, took #{(start-end_time)} seconds"
		puts "took #{end_time_shapes-start} seconds to process the shapes, took #{(end_time-end_time_shapes)} seconds to process the event and their shapes"
	end

end
