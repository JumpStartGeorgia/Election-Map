module JsonCache
	require 'fileutils'
	require 'net/http'

	###########################################
	### manage files
	###########################################
	def self.create_directory(event_id, subpath=nil)
		if !subpath.nil? && subpath != "."
			FileUtils.mkpath(json_file_path.gsub("[event_id]", event_id.to_s) + "/" + subpath)
		else
			FileUtils.mkpath(json_file_path.gsub("[event_id]", event_id.to_s))
		end
	end

	def self.read(event_id, filename)
		json = nil
		if event_id && filename
			file_path = json_file_path.gsub("[event_id]", event_id.to_s) << "/#{filename}.json"
			if File.exists?(file_path)
				json = File.open(file_path, "r") {|f| f.read()}
			end
		end
		return json
	end

	def self.fetch(event_id, filename, &block)
		json = nil
		if event_id && filename
			file_path = json_file_path.gsub("[event_id]", event_id.to_s) << "/#{filename}.json"
			if File.exists?(file_path)
				json = File.open(file_path, "r") {|f| f.read()}
			else
				# get the json data
				json = yield if block_given?

				# create the directory tree if it does not exist
				create_directory(event_id, File.dirname(filename))

				File.open(file_path, 'w') {|f| f.write(json)}
			end
		end
		return json
	end

	###########################################
	### clear cache
	###########################################
	# remove the files for the provided event_id
	# if no id provided, remove all files
	def self.clear_all(event_id=nil)
		Rails.logger.debug "################## - clearing all cache"
		clear_cache
		clear_files(event_id)
	end

	def self.clear_cache
		Rails.logger.debug "################## - clearing memory cache"
		Rails.cache.clear
	end

	def self.clear_files(event_id=nil)
		Rails.logger.debug "################## - clearing cache files"
		if event_id
			FileUtils.rm_rf(json_file_path.gsub("[event_id]", event_id.to_s))
		else
			# don't delete the json folder - delete everything inside it
			FileUtils.rm_rf(Dir.glob(json_file_path.gsub("event_[event_id]", "*")))
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

		start = Time.now
		Rails.logger.debug "============ starting build cache at #{start}"
		# get the events that have shapes assigned to them
		# if no shape assigned, then not appearing on site
		events = Event.where("shape_id is not null")
#		events = Event.where("id in (1,2,3,4,5,15,16)")
		if !events.nil? && !events.empty?
			events.each_with_index do |event, i|
				event_start = Time.now
				shape_type_id = event.shape.shape_type_id
				# if have offical data, get the most current dataset
				if event.has_official_data?
					dataset = DataSet.current_dataset(event.id, Datum::DATA_TYPE[:official])

					if dataset && !dataset.empty?
						# build default event cache
						build_event_default_cache(event, dataset.first.id, dataset.first.data_type, event.shape_id, shape_type_id)
					end
				end

				# if have live data, get the most current dataset
				if event.has_live_data?
					dataset = DataSet.current_dataset(event.id, Datum::DATA_TYPE[:live])

					if dataset && !dataset.empty?
						# build default event cache
						build_event_default_cache(event, dataset.first.id, dataset.first.data_type, event.shape_id, shape_type_id)
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

		Rails.logger.debug "=================== "
		Rails.logger.debug "============ total time took #{(end_time - start)} seconds"
		Rails.logger.debug "=================== "
  end

	# create cache for all indicators for all events that have a custom view
  def self.custom_event_indicator_cache
		start = Time.now

		# get the events that have custom views
    custom_views = EventCustomView.all
#		custom_views = EventCustomView.where("event_id in (1,2,3,4,5,15,16)")
		if !custom_views.nil? && !custom_views.empty?
      custom_views.each do |custom_view|
        # event must have shape attached to it
        if !custom_view.event.shape_id.nil?
          event_indicator_cache(custom_view.event_id, custom_view.descendant_shape_type_id)
        end
      end
    end
		Rails.logger.debug "=================== "
		Rails.logger.debug "============ total custom event indicator time took #{(Time.now - start)} seconds"
		Rails.logger.debug "=================== "
  end

	# create cache for all indicators in an event at a shape level
  def self.event_indicator_cache(event_id, shape_type_id)
    # turn off the active record logging
    old_logger = ActiveRecord::Base.logger
    ActiveRecord::Base.logger = nil

		start = Time.now
		Rails.logger.debug "============ starting build cache at #{start}"

		if !event_id.nil? && !shape_type_id.nil?
			# get the event
			event = Event.find(event_id)
			if !event.nil?
				# if have offical data, get the most current dataset
				if event.has_official_data?
					dataset = DataSet.current_dataset(event.id, Datum::DATA_TYPE[:official])

					if dataset && !dataset.empty?
						#build custom indicator cache
						build_event_indicator_cache(event, dataset.first.id, dataset.first.data_type, event.shape_id, shape_type_id, false, true)
					end
				end

				# if have live data, get the most current dataset
				if event.has_live_data?
					dataset = DataSet.current_dataset(event.id, Datum::DATA_TYPE[:live])

					if dataset && !dataset.empty?
						#build custom indicator cache
						build_event_indicator_cache(event, dataset.first.id, dataset.first.data_type, event.shape_id, shape_type_id, false, true)
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
				# if have offical data, get the most current dataset
				if event.has_official_data?
Rails.logger.debug "------------------ has official data"
					dataset = DataSet.current_dataset(event.id, Datum::DATA_TYPE[:official])

					if dataset && !dataset.empty?
						# get the summary data for each shape
						shapes.each do |shape|
							I18n.available_locales.each do |locale|
								I18n.locale = locale
								Datum.get_indicator_type_data(shape.id, shape.shape_type_id, event.id, event.indicator_type_id, dataset.first.id)
							end
						end
					end
				end

				# if have live data, get the most current dataset
				if event.has_live_data?
Rails.logger.debug "------------------ has live data"
					dataset = DataSet.current_dataset(event.id, Datum::DATA_TYPE[:live])

					if dataset && !dataset.empty?
						# get the summary data for each shape
						shapes.each do |shape|
							I18n.available_locales.each do |locale|
								I18n.locale = locale
								Datum.get_indicator_type_data(shape.id, shape.shape_type_id, event.id, event.indicator_type_id, dataset.first.id)
							end
						end
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


	###########################################
	### create data_set json cache
	###########################################
  def self.build_data_set_json_cache(event_id, data_set_id)
    # turn off the active record logging
    old_logger = ActiveRecord::Base.logger
    ActiveRecord::Base.logger = nil

    start = Time.now

		Rails.logger.debug "============ starting build cache at #{start}"
		# get the events that have shapes assigned to them
		# if no shape assigned, then not appearing on site
		event = Event.find(event_id)
		dataset = DataSet.find(data_set_id)
		if event && dataset
			shape_type_id = event.shape.shape_type_id

			# build default event cache
			build_event_default_cache(event, data_set_id, dataset.data_type, event.shape_id, shape_type_id)

			#build custom indicator cache
			build_event_indicator_cache(event, data_set_id, dataset.data_type, event.shape_id, shape_type_id)
		end

		end_time = Time.now

    # turn active record logging back on
    ActiveRecord::Base.logger = old_logger

		Rails.logger.debug "=================== "
		Rails.logger.debug "============ total time took #{(end_time - start)} seconds"
		Rails.logger.debug "=================== "
  end



protected

	def self.json_file_path
		"#{Rails.root}/public/json/event_[event_id]"
	end

	def self.json_domain
		# domain
		domain = "http://emap.local"
		if Rails.env.staging?
			domain = "http://dev-electiondata.jumpstart.ge"
		elsif Rails.env.production?
			domain = "http://data.electionportal.ge"
		end
		Rails.logger.debug "============ using domain #{domain}"
		return domain
	end

	###########################################
	### create the cache for an event's default view
	###########################################
	def self.build_event_default_cache(event, data_set_id, data_type, shape_id, shape_type_id)
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
						uri = URI("#{json_domain}/#{locale}/json/summary_custom_children_shapes/#{shape_id}/shape_type/#{shape_type_id}/event/#{event.id}/indicator_type/#{indicator_types[0].id}?custom_view=#{is_custom_view}&data_set_id=#{data_set_id}&data_type=#{data_type}")
					else
						uri = URI("#{json_domain}/#{locale}/json/summary_children_shapes/#{shape_id}/shape_type/#{shape_type_id}/event/#{event.id}/indicator_type/#{indicator_types[0].id}?custom_view=#{is_custom_view}&data_set_id=#{data_set_id}&data_type=#{data_type}")
					end
					Net::HTTP.get(uri)
				end
			elsif !indicator_types[0].core_indicators.nil? && !indicator_types[0].core_indicators.empty? &&
						!indicator_types[0].core_indicators[0].indicators.nil? && !indicator_types[0].core_indicators[0].indicators.empty?
				I18n.available_locales.each do |locale|
					# load the children shapes
					if is_custom_view
						uri = URI("#{json_domain}/#{locale}/json/custom_children_shapes/#{shape_id}/shape_type/#{shape_type_id}/event/#{event.id}/indicator/#{indicator_types[0].core_indicators[0].indicators[0].id}/custom_view/#{is_custom_view}?data_set_id=#{data_set_id}&data_type=#{data_type}")
					else
						uri = URI("#{json_domain}/#{locale}/json/children_shapes/#{shape_id}/shape_type/#{shape_type_id}/event/#{event.id}/parent_clickable/false/indicator/#{indicator_types[0].core_indicators[0].indicators[0].id}/custom_view/#{is_custom_view}?data_set_id=#{data_set_id}&data_type=#{data_type}")
					end
					Net::HTTP.get(uri)
				end
			end
		end
	end

	###########################################
	### create the cache for each of the event's
	### indicators for custom views
	###########################################
	def self.build_event_indicator_cache(event, data_set_id, data_type, shape_id, shape_type_id, check_custom_view = true, is_custom_view = false)

		if check_custom_view
			# see if event has custom view
			custom_view = event.event_custom_views.where(:shape_type_id => shape_type_id)
			if !custom_view.nil? && !custom_view.empty? && custom_view.first.is_default_view
				# has custom view, use the custom shape type
				shape_type_id = custom_view.first.descendant_shape_type_id
				is_custom_view = true
			end
		end

		indicators = Indicator.where(:event_id => event.id, :shape_type_id => shape_type_id)
		if !indicators.nil? && !indicators.empty?
			I18n.available_locales.each do |locale|
				indicators.each do |indicator|
					ind_start = Time.now
					# load the children shapes
					if is_custom_view
						uri = URI("#{json_domain}/#{locale}/json/custom_children_shapes/#{shape_id}/shape_type/#{shape_type_id}/event/#{event.id}/indicator/#{indicator.id}/custom_view/#{is_custom_view}?data_set_id=#{data_set_id}&data_type=#{data_type}")
					else
						uri = URI("#{json_domain}/#{locale}/json/children_shapes/#{shape_id}/shape_type/#{shape_type_id}/event/#{event.id}/parent_clickable/false/indicator/#{indicator.id}/custom_view/#{is_custom_view}?data_set_id=#{data_set_id}&data_type=#{data_type}")
					end
					Net::HTTP.get(uri)
		    end
			end
		end
	end
end
