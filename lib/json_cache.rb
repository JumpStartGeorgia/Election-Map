module JsonCache
	require 'fileutils'
	require 'net/http'

#	json_file_path = "#{Rails.root}/public/json/event_[event_id]"
	JSON_ROOT_PATH = "#{Rails.root}/public/system/json"
	JSON_SHAPE_PATH = "#{JSON_ROOT_PATH}/shapes"
	JSON_DATA_PATH = "#{JSON_ROOT_PATH}/data"

	###########################################
	### manage files
	###########################################
	def self.read_shape(filename)
		json = nil
		json = read(JSON_SHAPE_PATH + "/#{filename}.json") if filename
		return json
	end

	def self.read_data(filename)
		json = nil
		json = read(JSON_DATA_PATH + "/#{filename}.json") if filename
		return json
	end

	def self.fetch_shape(filename, &block)
		json = nil
		if filename
			json = fetch(JSON_SHAPE_PATH + "/#{filename}.json") {yield if block_given?}
		end
		return json
	end

	def self.fetch_data(filename, &block)
		json = nil
		if filename
			json = fetch(JSON_DATA_PATH + "/#{filename}.json") {yield if block_given?}
		end
		return json
	end

	###########################################
	### clear cache
	###########################################
	def self.clear_all
		Rails.logger.debug "################## - clearing all file and memory cache"
		clear_memory_cache
		clear_all_files
	end

	def self.clear_all_shapes
		Rails.logger.debug "################## - clearing all shape and memory cache"
		clear_memory_cache
		clear_shape_files
	end

	def self.clear_all_data(event_id = nil)
		Rails.logger.debug "################## - clearing all data and memory cache"
		clear_memory_cache
		clear_data_files(event_id)
	end

	def self.clear_memory_cache
		Rails.logger.debug "################## - clearing memory cache"
		Rails.cache.clear
	end

	def self.clear_all_files
		Rails.logger.debug "################## - clearing cache files"
		# don't delete the json folder - delete everything inside it
		FileUtils.rm_rf(Dir.glob(JSON_ROOT_PATH + "/*"))
	end

	def self.clear_shape_files
		Rails.logger.debug "################## - clearing shape cache files"
		FileUtils.rm_rf(JSON_SHAPE_PATH)
	end

	def self.clear_data_files(event_id=nil)
		Rails.logger.debug "################## - clearing data cache files"
		if event_id
			FileUtils.rm_rf(JSON_DATA_PATH.gsub("[event_id]", event_id.to_s))
		else
			FileUtils.rm_rf(JSON_DATA_PATH)
		end
	end

	###########################################
	### create custom view event json cache
	###########################################
  def self.build_default_and_custom_cache
    start = Time.now

    default_event_cache
    default_time = Time.now

    custom_event_indicator_cache
    custom_time = Time.now

		Rails.logger.debug "======================================================== "
		Rails.logger.debug "======== time to load default events was #{(default_time - start)} seconds"
		Rails.logger.debug "======== time to load custom view cache was #{(custom_time - default_time)} seconds"
		Rails.logger.debug "======== total time was #{(Time.now - start)} seconds"
		Rails.logger.debug "======================================================== "

  end

	# create the cache for all events and their default view
  def self.default_event_cache
    # turn off the active record logging
    old_logger = ActiveRecord::Base.logger
    ActiveRecord::Base.logger = nil

		# domain
		domain = "http://0.0.0.0:3000"
		if Rails.env.staging?
			domain = "http://dev-electiondata.jumpstart.ge"
		elsif Rails.env.production?
			domain = "http://data.electionportal.ge"
		end
		Rails.logger.debug "============ using domain #{domain}"

		start = Time.now
		Rails.logger.debug "============ starting build cache at #{start}"
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
							# load the children shapes
              if is_custom_view
							  uri = URI("#{domain}/#{locale}/json/summary_custom_children_shapes/#{event.shape_id}/shape_type/#{shape_type_id}/event/#{event.id}/indicator_type/#{indicator_types[0].id}?custom_view=#{is_custom_view}")
							else
							  uri = URI("#{domain}/#{locale}/json/summary_children_shapes/#{event.shape_id}/shape_type/#{shape_type_id}/event/#{event.id}/indicator_type/#{indicator_types[0].id}?custom_view=#{is_custom_view}")
						  end
							Net::HTTP.get(uri)
						end
					elsif !indicator_types[0].core_indicators.nil? && !indicator_types[0].core_indicators.empty? &&
								!indicator_types[0].core_indicators[0].indicators.nil? && !indicator_types[0].core_indicators[0].indicators.empty?
						I18n.available_locales.each do |locale|
							# load the children shapes
							if is_custom_view
							  uri = URI("#{domain}/#{locale}/json/custom_children_shapes/#{event.shape_id}/shape_type/#{shape_type_id}/event/#{event.id}/indicator/#{indicator_types[0].core_indicators[0].indicators[0].id}/custom_view/#{is_custom_view}")
							else
							  uri = URI("#{domain}/#{locale}/json/children_shapes/#{event.shape_id}/shape_type/#{shape_type_id}/event/#{event.id}/parent_clickable/false/indicator/#{indicator_types[0].core_indicators[0].indicators[0].id}/custom_view/#{is_custom_view}")
						  end
							Net::HTTP.get(uri)
						end
					end
					Rails.logger.debug "=================== "
					Rails.logger.debug "=================== time to load event #{event.id} was #{(Time.now-event_start)} seconds"
					Rails.logger.debug "=================== "
				end
			end
		end

		end_time = Time.now

    # turn active record logging back on
    ActiveRecord::Base.logger = old_logger

		Rails.logger.debug "============ total time took #{(end_time - start)} seconds"
  end

	# create cache for all indicators for all events that have a custom view
  def self.custom_event_indicator_cache

		# get the events that have custom views
    custom_views = EventCustomView.all
		if !custom_views.nil? && !custom_views.empty?
      custom_views.each do |custom_view|
        # event must have shape attached to it
        if !custom_view.event.shape_id.nil?
          event_indicator_cache(custom_view.event_id, custom_view.descendant_shape_type_id)
        end
      end
    end
  end

	# create cache for all indicators in an event at a shape level
  def self.event_indicator_cache(event_id, shape_type_id)
    # turn off the active record logging
    old_logger = ActiveRecord::Base.logger
    ActiveRecord::Base.logger = nil

		start = Time.now
		Rails.logger.debug "============ starting build cache at #{start}"

		if !event_id.nil? && !shape_type_id.nil?
			# domain
			domain = "http://0.0.0.0:3000"
			if Rails.env.staging?
				domain = "http://dev-electiondata.jumpstart.ge"
			elsif Rails.env.production?
				domain = "http://data.electionportal.ge"
			end
			Rails.logger.debug "============ using domain #{domain}"

			# get the event
			event = Event.find(event_id)
			if !event.nil?
				# see if event has custom view at this shape type
				custom_view = event.event_custom_views.where(:descendant_shape_type_id => shape_type_id)
        is_custom_view = false
				if !custom_view.nil? && !custom_view.empty? && custom_view.first.is_default_view
					# has custom view, use the custom shape type
  				Rails.logger.debug "=================== "
					Rails.logger.debug "=================== event #{event_id} at shape type #{shape_type_id} is a custom view"
  				Rails.logger.debug "=================== "
					is_custom_view = true
				end

				# get all indicators for this event and shape type
				indicators = Indicator.where(:event_id => event_id, :shape_type_id => shape_type_id)
				if !indicators.nil? && !indicators.empty?
					I18n.available_locales.each do |locale|
  				  indicators.each do |indicator|
      				ind_start = Time.now
    					# load the children shapes
    					if is_custom_view
							  uri = URI("#{domain}/#{locale}/json/custom_children_shapes/#{event.shape_id}/shape_type/#{shape_type_id}/event/#{event.id}/indicator/#{indicator.id}/custom_view/#{is_custom_view}")
							else
							  uri = URI("#{domain}/#{locale}/json/children_shapes/#{event.shape_id}/shape_type/#{shape_type_id}/event/#{event.id}/parent_clickable/false/indicator/#{indicator.id}/custom_view/#{is_custom_view}")
    				  end
							Net::HTTP.get(uri)
      				Rails.logger.debug "=================== "
    					Rails.logger.debug "=================== time to load indicator #{indicator.id} for event #{event.id} was #{(Time.now-ind_start)} seconds"
    					Rails.logger.debug "=================== "
            end
  				end
				end
			end
		end
		end_time = Time.now

    # turn active record logging back on
    ActiveRecord::Base.logger = old_logger
		Rails.logger.debug "============ total time took #{(end_time - start)} seconds"
	end

	###########################################
	### create summary data json file
	###########################################
	# create the cache of summary data for all events and all of their shapes
  def self.summary_data_cache
    # turn off the active record logging
    old_logger = ActiveRecord::Base.logger
    ActiveRecord::Base.logger = nil

		start = Time.now
		Rails.logger.debug "============ starting build cache at #{start}"
		# get the events that have indicators with a type that has a summary
		events = Event.get_events_with_summary_indicators
		if !events.nil? && !events.empty?
#			events = events.select{|x| x.id == 15 || x.id == 2}
			events.each_with_index do |event, i|
				event_start = Time.now
				Rails.logger.debug "=================== "
				Rails.logger.debug "=================== event #{event.id} start"
				Rails.logger.debug "=================== "

				# get all of the shapes for this event
				# - have to call root for the default event shape may not be the root shape
				shapes = event.shape.root.subtree
#				shapes = event.shape.root.subtree.where("shape_type_id in (1,2,3)")
				# get the summary data for each shape
				shapes.each do |shape|
					I18n.available_locales.each do |locale|
						I18n.locale = locale
						Datum.build_summary_data_json(shape.id, shape.shape_type_id, event.id, event.indicator_type_id)
					end
				end

				Rails.logger.debug "=================== "
				Rails.logger.debug "=================== time to load event #{event.id} was #{(Time.now-event_start)} seconds"
				Rails.logger.debug "=================== "
			end
		end

		end_time = Time.now

    # turn active record logging back on
    ActiveRecord::Base.logger = old_logger

		Rails.logger.debug "============ total time took #{(end_time - start)} seconds"
  end

protected
	###########################################
	### manage files
	###########################################
	def self.create_directory(file_path)
		if !file_path.nil? && file_path != "."
			FileUtils.mkpath(file_path)
		end
	end

	def self.read(file_path)
		json = nil
		if file_path && File.exists?(file_path)
			json = File.open(file_path, "r") {|f| f.read()}
		end
		return json
	end

	def self.fetch(file_path, &block)
		json = nil
		if file_path
			if File.exists?(file_path)
				json = File.open(file_path, "r") {|f| f.read()}
			else
				# get the json data
				json = yield if block_given?

				# create the directory tree if it does not exist
				create_directory(File.dirname(file_path))

				File.open(file_path, 'w') {|f| f.write(json)}
			end
		end
		return json
	end


end
