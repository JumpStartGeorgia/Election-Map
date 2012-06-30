module TimeTest

  def self.load_summaries
		# clear the cache
		Rails.cache.clear
		count = 0

		start = Time.now
		Rails.logger.debug "start time = #{start}"

		# cache shape summary json for each election event
		events = Event.where(:event_type_id => 1)

		events.each do |event|
			if !event.shape_id.nil?
				app.get "/en/json/summary_grandchildren_shapes/#{event.shape_id}/event/#{event.id}/indicator_type/2"
      end
    end

		end_time = Time.now

		Rails.logger.debug "end time = #{end_time}, took #{(start-end_time)} seconds"
  end

	def self.run_test
		# clear the cache
		Rails.cache.clear
		count = 0

		start = Time.now
		Rails.logger.debug "start time = #{start}"

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

		Rails.logger.debug "end time = #{end_time}, took #{(start-end_time)} seconds"
		Rails.logger.debug "took #{end_time_shapes-start} seconds to process the shapes, took #{(end_time-end_time_shapes)} seconds to process the event and their shapes"
	end

end
