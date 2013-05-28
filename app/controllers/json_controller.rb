class JsonController < ApplicationController
  layout false
	require 'json'

	MEMORY_CACHE_KEY_SHAPE = "shape/[locale]/shape_[shape_id]/shape_type_[shape_type_id]"
	MEMORY_CACHE_KEY_CHILDREN_SHAPES =
		"children_shapes/[locale]/shape_[parent_id]/shape_type_[shape_type_id]/parent_clickable_[parent_shape_clickable]"
	FILE_CACHE_KEY_CUSTOM_CHILDREN_SHAPES = "custom_chlidren_shapes/[locale]/shape_type_[shape_type_id]/shape_[parent_id]"

	MEMORY_CACHE_KEY_CHILDREN_DATA =
		"event_[event_id]/data_set_[data_set_id]/[locale]/children_data/shape_[parent_id]/shape_type_[shape_type_id]/indicator_[indicator_id]/parent_clickable_[parent_shape_clickable]"
	MEMORY_CACHE_KEY_SUMMARY_CHILDREN_DATA =
		"event_[event_id]/data_set_[data_set_id]/[locale]/summary_children_data/shape_[parent_id]/shape_type_[shape_type_id]/indicator_type[indicator_type_id]/parent_clickable_[parent_shape_clickable]"

	FILE_CACHE_KEY_CUSTOM_CHILDREN_DATA =
		"event_[event_id]/data_set_[data_set_id]/[locale]/custom_children_data/shape_type_[shape_type_id]/shape_[parent_id]_indicator_[indicator_id]"
	FILE_CACHE_KEY_SUMMARY_CUSTOM_CHILDREN_DATA =
		"event_[event_id]/data_set_[data_set_id]/[locale]/summary_custom_children_data/shape_type_[shape_type_id]/shape_[parent_id]_indicator_type_[indicator_type_id]"



  SUMMARY_LIMIT = 5



	#################################################
	##### core indicator events
	#################################################
  # GET /json/core_indicator_events
  def core_indicator_events
    start = Time.now

    # action is in app controller
		json = get_core_indicator_events

    respond_to do |format|
      format.json { render json: json}
    end
		logger.debug "@ time to render core indicator events json: #{Time.now-start} seconds"
  end

  # GET /json/core_indicator_events_table
  # format: 
  # [
  #  {header => []},
  #  {indicator_types => [
  #   {id, name, indicators => [
  #     [id, name abbrv, name, et1, et2, et3, ...],  
  #     [id, name abbrv, name, et1, et2, et3, ...],  
  #   ]}
  #  ]},
  # ]
  def core_indicator_events_table
    start = Time.now

    # action is in app controller
		json = get_core_indicator_events_table

    respond_to do |format|
      format.json { render json: json}
    end
		logger.debug "@ time to render core indicator events table json: #{Time.now-start} seconds"
  end

	#################################################
	##### event menu
	#################################################
  # GET /:locale/json/event_menu
  def event_menu
		# the menu is create in the application controller
    respond_to do |format|
      format.json { render json: @event_menu.to_json }
    end
  end

  # GET /:locale/json/live_event_menu
  def live_event_menu
		# the menu is create in the application controller
    respond_to do |format|
      format.json { render json: @live_event_menu.to_json }
    end
  end


	#################################################
	##### get most recent dataset id for event
	#################################################
  # GET /:locale/json/current_data_set_id/:event_id/:data_type
  def current_data_set
		data_set_id = get_data_set_id(params[:event_id], params[:data_type])

    respond_to do |format|
      format.json { render json: data_set_id.to_json }
    end
  end

	#################################################
	##### shape jsons
	#################################################
  # GET /json/shape/:id/shape_type/:shape_type_id
  def shape
=begin
		geometries = Rails.cache.fetch(MEMORY_CACHE_KEY_SHAPE.gsub("[shape_id]", params[:id])
				.gsub("[locale]", I18n.locale.to_s)
				.gsub("[shape_type_id]", params[:shape_type_id])) {
			Shape.build_json(params[:id], params[:shape_type_id]).to_json
		}
=end
    geometries = Shape.build_json(params[:id], params[:shape_type_id]).to_json

    respond_to do |format|
      format.json { render json: geometries }
    end
  end

  # GET /json/children_shapes/:parent_id/shape_type/:shape_type_id/event/:event_id(/parent_clickable/:parent_shape_clickable)
  def children_shapes
    start = Time.now
		geometries = nil
		# get parent of parent shape and see if custom_children cache already exists
		shape = Shape.find(params[:parent_id])
		# see if this event at this shape type is a custom view
		custom = EventCustomView.get_by_descendant(params[:event_id], params[:shape_type_id])

		parent_shape = nil
		if !shape.nil?
		  if custom && !custom.empty?
				logger.debug "++++++++++event has custom shape at shape type #{custom.first.shape_type_id}, checking for file cache"
  			parent_shape = shape.ancestors.where(:shape_type_id => custom.first.shape_type_id)
  			custom_children_cache = nil
  			if !parent_shape.nil? && !parent_shape.empty?
					key = FILE_CACHE_KEY_CUSTOM_CHILDREN_SHAPES.gsub("[parent_id]", parent_shape.first.id.to_s)
						.gsub("[locale]", I18n.locale.to_s)
						.gsub("[shape_type_id]", params[:shape_type_id])
  				logger.debug "++++++++++custom children key = #{key}"
  				custom_children_cache = JsonCache.read_shape(key)
  			end

  			if !custom_children_cache.nil?
  				# cache exists, pull out need shapes
  				logger.debug "++++++++++custom children cache exists, pulling out desired shapes"

          geometries = JSON.parse(custom_children_cache)
          needed = []
          geometries['features'].each do |value|
            if value['properties']['parent_id'].to_s == params[:parent_id]
              needed << value
            end
          end
          geometries['features'] = needed
  			end
      end

      # if geometries is still nil, get data from database
      if geometries.nil?
				logger.debug "++++++++++custom children cache does NOT exist"
				# no cache exists
				key = MEMORY_CACHE_KEY_CHILDREN_SHAPES.gsub("[parent_id]", params[:parent_id])
					.gsub("[locale]", I18n.locale.to_s)
				  .gsub("[shape_type_id]", params[:shape_type_id])
				if params[:parent_shape_clickable]
					key.gsub!("[parent_shape_clickable]", params[:parent_shape_clickable])
				else
					key.gsub!("[parent_shape_clickable]", "false")
				end
=begin
				geometries = Rails.cache.fetch(key) {
					geo = ''

					if !params[:parent_shape_clickable].nil? && params[:parent_shape_clickable].to_s == "true"
						geo = Shape.build_json(shape.id, shape.shape_type_id).to_json
					elsif shape.has_children?
						geo = Shape.build_json(shape.id, params[:shape_type_id]).to_json
					end
					geo
				}
=end
        if !params[:parent_shape_clickable].nil? && params[:parent_shape_clickable].to_s == "true"
	        geometries = Shape.build_json(shape.id, shape.shape_type_id).to_json
        elsif shape.has_children?
	        geometries = Shape.build_json(shape.id, params[:shape_type_id]).to_json
        end

			end
		end

    respond_to do |format|
      format.json { render json: geometries}
    end
    logger.debug "@ time to render children_shapes json: #{Time.now-start} seconds"
  end

  # GET /json/custom_children_shapes/:parent_id/shape_type/:shape_type_id
  def custom_children_shapes
    start = Time.now
		key = FILE_CACHE_KEY_CUSTOM_CHILDREN_SHAPES.gsub("[parent_id]", params[:parent_id])
			.gsub("[locale]", I18n.locale.to_s)
		  .gsub("[shape_type_id]", params[:shape_type_id])
		geometries = JsonCache.fetch_shape(key) {
  		Shape.build_json(params[:parent_id], params[:shape_type_id]).to_json
		}

		logger.debug "++++++++++custom children key = #{key}"
    respond_to do |format|
      format.json { render json: geometries}
    end
		logger.debug "@ time to render custom_children_shapes json: #{Time.now-start} seconds"
  end

	#################################################
	##### children data jsons
	#################################################
  # GET /json/children_data/:parent_id/shape_type/:shape_type_id/event/:event_id/indicator/:indicator_id(/parent_clickable/:parent_shape_clickable)
  def children_data
    # if the ind id is not a number, do not continue
    test = Integer(params[:indicator_id]) rescue nil
    if test.nil?
      respond_to do |format|
        format.json { render json: nil.to_json }
      end
      return
    end

    start = Time.now
		data = nil

		# get data set id if not provided
		if params[:data_set_id].nil?
			params[:data_set_id] = get_data_set_id(params[:event_id], params[:data_type]).to_s
		end

		if params[:data_set_id]
		  # get parent of parent shape and see if custom_children cache already exists
		  shape = Shape.find(params[:parent_id])
		  # see if this event at this shape type is a custom view
		  custom = EventCustomView.get_by_descendant(params[:event_id], params[:shape_type_id])

		  parent_shape = nil
		  if !shape.nil?
		    if custom && !custom.empty?
				  logger.debug "++++++++++event has custom shape at shape type #{custom.first.shape_type_id}, checking for file cache"
    			parent_shape = shape.ancestors.where(:shape_type_id => custom.first.shape_type_id)
    			custom_children_cache = nil
    			if !parent_shape.nil? && !parent_shape.empty?
					  key = FILE_CACHE_KEY_CUSTOM_CHILDREN_DATA.gsub("[parent_id]", parent_shape.first.id.to_s)
						  .gsub("[locale]", I18n.locale.to_s)
			        .gsub("[event_id]", params[:event_id])
						  .gsub("[indicator_id]", params[:indicator_id])
						  .gsub("[shape_type_id]", params[:shape_type_id])
  		        .gsub("[data_set_id]", params[:data_set_id])
    				logger.debug "++++++++++custom children key = #{key}"
    				custom_children_cache = JsonCache.read_data(key)
    			end

    			if !custom_children_cache.nil?
    				# cache exists, pull out shapes that have this parent_id
    				logger.debug "++++++++++custom children cache exists, pulling out desired shapes"
            json = JSON.parse(custom_children_cache)
					  shape_data = json["shape_data"].select{|x| x.first.has_key?("shape_values") && !x.first["shape_values"].nil? && !x.first["shape_values"].empty? && x.first["shape_values"]["parent_id"].to_s == params[:parent_id]}
					  json["shape_data"] = shape_data

					  data = json if json.present?
    			end
        end

        # if data is still nil, get data from database
        if data.nil?
				  logger.debug "++++++++++custom children cache does NOT exist"
				  # no cache exists
				  key = MEMORY_CACHE_KEY_CHILDREN_DATA.gsub("[parent_id]", params[:parent_id])
					  .gsub("[locale]", I18n.locale.to_s)
		        .gsub("[event_id]", params[:event_id])
					  .gsub("[indicator_id]", params[:indicator_id])
				    .gsub("[shape_type_id]", params[:shape_type_id])
		        .gsub("[data_set_id]", params[:data_set_id])
				  if params[:parent_shape_clickable]
					  key.gsub!("[parent_shape_clickable]", params[:parent_shape_clickable])
				  else
					  key.gsub!("[parent_shape_clickable]", "false")
				  end
=begin
			    data = Rails.cache.fetch(key) {
				    d = ''
				    if !params[:parent_shape_clickable].nil? && params[:parent_shape_clickable].to_s == "true"
					    d = Datum.build_json(shape.id, shape.shape_type_id, params[:indicator_id], params[:data_set_id], params[:data_type], params[:data_type]).to_json
				    elsif shape.has_children?
					    d = Datum.build_json(shape.id, params[:shape_type_id], params[:indicator_id], params[:data_set_id], params[:data_type], params[:data_type]).to_json
				    end
				    d
			    }
=end
          if !params[:parent_shape_clickable].nil? && params[:parent_shape_clickable].to_s == "true"
	          data = Datum.build_json(shape.id, shape.shape_type_id, params[:indicator_id], params[:data_set_id], params[:data_type]).to_json
          elsif shape.has_children?
	          data = Datum.build_json(shape.id, params[:shape_type_id], params[:indicator_id], params[:data_set_id], params[:data_type]).to_json
          end

			  end
		  end
    end

    respond_to do |format|
      format.json { render json: data}
    end
    logger.debug "@ time to render children_data json: #{Time.now-start} seconds"
  end

  # GET /json/custom_children_data/:parent_id/shape_type/:shape_type_id/event/:event_id/indicator_id/:indicator_id
  def custom_children_data
    # if the ind id is not a number, do not continue
    test = Integer(params[:indicator_id]) rescue nil
    if test.nil?
      respond_to do |format|
        format.json { render json: nil.to_json }
      end
      return
    end

    start = Time.now
		data = nil

		# get data set id if not provided
		if params[:data_set_id].nil?
			params[:data_set_id] = get_data_set_id(params[:event_id], params[:data_type]).to_s
		end

		if params[:data_set_id]
		  key = FILE_CACHE_KEY_CUSTOM_CHILDREN_DATA.gsub("[parent_id]", params[:parent_id])
			  .gsub("[locale]", I18n.locale.to_s)
        .gsub("[event_id]", params[:event_id])
			  .gsub("[indicator_id]", params[:indicator_id])
		    .gsub("[shape_type_id]", params[:shape_type_id])
        .gsub("[data_set_id]", params[:data_set_id])
  		logger.debug "++++++++++custom children key = #{key}"
		  data = JsonCache.fetch_data(key) {
			  Datum.build_json(params[:parent_id], params[:shape_type_id], params[:indicator_id], params[:data_set_id], params[:data_type]).to_json
		  }
    end

    respond_to do |format|
      format.json { render json: data}
    end
		logger.debug "@ time to render custom_children_data json: #{Time.now-start} seconds"
  end

	#################################################
	##### summary children data jsons
	#################################################
  # GET /json/summary_children_data/:parent_id/shape_type/:shape_type_id/event/:event_id/indicator_type/:indicator_type_id
  def summary_children_data
    # if the ind type id is not a number, do not continue
    test = Integer(params[:indicator_type_id]) rescue nil
    if test.nil?
      respond_to do |format|
        format.json { render json: nil.to_json }
      end
      return
    end

    start = Time.now
		data = nil

		# get data set id if not provided
		if params[:data_set_id].nil?
			params[:data_set_id] = get_data_set_id(params[:event_id], params[:data_type]).to_s
		end

		if params[:data_set_id]
		  # get parent of parent shape and see if custom_children cache already exists
		  shape = Shape.find(params[:parent_id])
		  # see if this event at this shape type is a custom view
		  custom = EventCustomView.get_by_descendant(params[:event_id], params[:shape_type_id])

		  parent_shape = nil
		  if !shape.nil?
		    if custom && !custom.empty?
				  logger.debug "++++++++++event has custom shape, checking for file cache"
    			parent_shape = shape.ancestors.where(:shape_type_id => custom.first.shape_type_id)
    			custom_children_cache = nil
    			if !parent_shape.nil?
				  key = FILE_CACHE_KEY_SUMMARY_CUSTOM_CHILDREN_DATA.gsub("[parent_id]", parent_shape.first.id.to_s)
					  .gsub("[locale]", I18n.locale.to_s)
				    .gsub("[event_id]", params[:event_id])
				    .gsub("[indicator_type_id]", params[:indicator_type_id])
				    .gsub("[shape_type_id]", params[:shape_type_id])
				    .gsub("[data_set_id]", params[:data_set_id])

    				logger.debug "++++++++++custom children key = #{key}"
    				custom_children_cache = JsonCache.read_data(key)
    			end

    			if !custom_children_cache.nil?
    				# cache exists, pull out need shapes
    				logger.debug "++++++++++custom children cache exists, pulling out desired shapes"
            json = JSON.parse(custom_children_cache)
					  shape_data = json["shape_data"].select{|x| x.first.has_key?("shape_values") && !x.first["shape_values"].nil? && !x.first["shape_values"].empty? && x.first["shape_values"]["parent_id"].to_s == params[:parent_id]}
					  json["shape_data"] = shape_data

					  data = json if json.present?
    			end
        end

        # if data is still nil, get data from database
        if data.nil?
				  logger.debug "++++++++++custom children cache does NOT exist"
				  # no cache exists
				  key = MEMORY_CACHE_KEY_SUMMARY_CHILDREN_DATA.gsub("[parent_id]", params[:parent_id])
					  .gsub("[locale]", I18n.locale.to_s)
		        .gsub("[event_id]", params[:event_id])
					  .gsub("[indicator_type_id]", params[:indicator_type_id])
				    .gsub("[shape_type_id]", params[:shape_type_id])
				    .gsub("[data_set_id]", params[:data_set_id])
				  if params[:parent_shape_clickable]
					  key.gsub!("[parent_shape_clickable]", params[:parent_shape_clickable])
				  else
					  key.gsub!("[parent_shape_clickable]", "false")
				  end
=begin
				  data = Rails.cache.fetch(key) {
					  d = ''
					  if !params[:parent_shape_clickable].nil? && params[:parent_shape_clickable].to_s == "true"
  logger.debug "++++++++++++++++++++++++++++ getting summary with parent shape clickable"
						  d = Datum.build_summary_json(shape.id, shape.shape_type_id, params[:event_id], params[:indicator_type_id], params[:data_set_id], params[:data_type]).to_json
					  elsif shape.has_children?
  logger.debug "++++++++++++++++++++++++++++ getting summary with NO parent shape clickable"
						  d = Datum.build_summary_json(shape.id, params[:shape_type_id], params[:event_id], params[:indicator_type_id], params[:data_set_id], params[:data_type]).to_json
					  end
					  d
				  }
=end
          if !params[:parent_shape_clickable].nil? && params[:parent_shape_clickable].to_s == "true"
	          data = Datum.build_summary_json(shape.id, shape.shape_type_id, params[:event_id], params[:indicator_type_id], 
                    params[:data_set_id], params[:data_type], SUMMARY_LIMIT).to_json
          elsif shape.has_children?
	          data = Datum.build_summary_json(shape.id, params[:shape_type_id], params[:event_id], params[:indicator_type_id], 
                    params[:data_set_id], params[:data_type], SUMMARY_LIMIT).to_json
          end

			  end
		  end 
    end

    respond_to do |format|
      format.json { render json: data}
    end
    logger.debug "@ time to render summary_children_data json: #{Time.now-start} seconds"
  end

  # GET /json/summary_custom_children_data/:parent_id/shape_type/:shape_type_id/event/:event_id/indicator_type/:indicator_type_id
  def summary_custom_children_data
    # if the ind type id is not a number, do not continue
    test = Integer(params[:indicator_type_id]) rescue nil
    if test.nil?
      respond_to do |format|
        format.json { render json: nil.to_json }
      end
      return
    end

    start = Time.now
		data = nil
		# get data set id if not provided
		if params[:data_set_id].nil?
			params[:data_set_id] = get_data_set_id(params[:event_id], params[:data_type]).to_s
		end

		if params[:data_set_id]
		  key = FILE_CACHE_KEY_SUMMARY_CUSTOM_CHILDREN_DATA.gsub("[parent_id]", params[:parent_id])
					  .gsub("[locale]", I18n.locale.to_s)
		        .gsub("[event_id]", params[:event_id])
		        .gsub("[indicator_type_id]", params[:indicator_type_id])
		        .gsub("[shape_type_id]", params[:shape_type_id])
				    .gsub("[data_set_id]", params[:data_set_id])
		  data = JsonCache.fetch_data(key) {
			  Datum.build_summary_json(params[:parent_id], params[:shape_type_id], params[:event_id], 
              params[:indicator_type_id], params[:data_set_id], params[:data_type], SUMMARY_LIMIT).to_json
		  }
    end

    respond_to do |format|
      format.json { render json: data}
    end

    logger.debug "@ time to render summary_custom_children_data json: #{Time.now-start} seconds"
  end


	#################################################
	##### for the core indicator and event type, get each event summary data 
  ##### format: [{event, data}, {event, data}, ...]
	#################################################
  def indicator_event_type_summary_data
    data = nil
    indicators = JSON.parse(get_core_indicator_events)
    indicator = indicators.select{|x| x["id"].to_s == params[:core_indicator_id]}.first
    if indicator.present?
      event_type = indicator["event_types"].select{|x| x["id"].to_s == params[:event_type_id]}.first
      if event_type.present? && event_type["events"].present?
        data = []
        shapes = nil
        # get the ids of the shapes for the provided common id/name if provided
        if params[:shape_type_id].present? && params[:common_id].present? && params[:common_name].present?
          shapes = Shape.by_common_and_events(params[:shape_type_id], params[:common_id], params[:common_name], event_type["events"].map{|x| x["id"]})
        end

        event_type["events"].each do |event|
          shape_id = event["shape_id"].to_s
          shape_type_id = event["shape_type_id"].to_s
          s_index = shapes.present? ? shapes.index{|x| x[:event_id].to_s == event["id"].to_s} : nil
          if shapes && s_index.present?
            shape_id = shapes[s_index][:shape_id].to_s
            shape_type_id = shapes[s_index][:shape_type_id].to_s
          end

          if shape_id.present? && shape_type_id.present?
		        key = FILE_CACHE_KEY_SUMMARY_CUSTOM_CHILDREN_DATA.gsub("[parent_id]", shape_id)
					        .gsub("[locale]", I18n.locale.to_s)
		              .gsub("[event_id]", event["id"].to_s)
		              .gsub("[indicator_type_id]", indicator["type_id"].to_s)
		              .gsub("[shape_type_id]", shape_type_id)
				          .gsub("[data_set_id]", event["data_set_id"].to_s)
		        x = JSON.parse(JsonCache.fetch_data(key) {
			        Datum.build_summary_json(shape_id, shape_type_id, event["id"], 
                    indicator["type_id"], event["data_set_id"], event["data_type"]).to_json
		        })
          end
          # add event info
          y = Hash.new
          y[:event] = Hash.new
          y[:event][:id] = event["id"]
          y[:event][:name] = event["name"]
          z = x["shape_data"][0].select{|z| z.has_key?("summary_data")} if x.present?
          y[:data] = z.present? ? z.first["summary_data"]["data"] : nil
          data << y
        end
      end
    end

    respond_to do |format|
      format.json { render json: data.to_json}
    end
  end

	#################################################
	##### for the core indicator and event type, get each event data 
  ##### format: [{event, data}, {event, data}, ...]
	#################################################
  def indicator_event_type_data
    data = nil
    indicators = JSON.parse(get_core_indicator_events)
    indicator = indicators.select{|x| x["id"].to_s == params[:core_indicator_id]}.first
    if indicator.present?
      event_type = indicator["event_types"].select{|x| x["id"].to_s == params[:event_type_id]}.first
      if event_type.present? && event_type["events"].present?
        data = []
        shapes = nil
        # get the ids of the shapes for the provided common id/name if provided
        if params[:shape_type_id].present? && params[:common_id].present? && params[:common_name].present?
          shapes = Shape.by_common_and_events(params[:shape_type_id], params[:common_id], params[:common_name], event_type["events"].map{|x| x["id"]})
        end

        event_type["events"].each do |event|
          shape_id = event["shape_id"].to_s
          shape_type_id = event["shape_type_id"].to_s
          s_index = shapes.present? ? shapes.index{|x| x[:event_id].to_s == event["id"].to_s} : nil
          if shapes && s_index.present?
            shape_id = shapes[s_index][:shape_id].to_s
            shape_type_id = shapes[s_index][:shape_type_id].to_s
          end

          # get the indicator for this event and shape type 
          indicator_id = Indicator.find_by_event_shape_type(event["id"],shape_type_id).where(:core_indicator_id => params[:core_indicator_id]).map{|x| x.id}.first

          if shape_id.present? && shape_type_id.present? && indicator_id.present?
		        key = FILE_CACHE_KEY_CUSTOM_CHILDREN_DATA.gsub("[parent_id]", shape_id)
					        .gsub("[locale]", I18n.locale.to_s)
		              .gsub("[event_id]", event["id"].to_s)
    			        .gsub("[indicator_id]", indicator_id.to_s)
		              .gsub("[shape_type_id]", shape_type_id)
				          .gsub("[data_set_id]", event["data_set_id"].to_s)
		        x = JSON.parse(JsonCache.fetch_data(key) {
			        Datum.build_json(shape_id, shape_type_id, indicator_id, event["data_set_id"], event["data_type"]).to_json
		        })
          end
          # add event info
          y = Hash.new
          y[:event] = Hash.new
          y[:event][:id] = event["id"]
          y[:event][:name] = event["name"]
          z = x["shape_data"][0].select{|z| z.has_key?("data_item")} if x.present?
          y[:data] = z.present? ? z : nil
          data << y
        end
      end
    end

    respond_to do |format|
      format.json { render json: data.to_json}
    end
  end

protected
	# if a data set id is not passed in, use the current dataset
	def get_data_set_id(event_id, data_type)
		dataset = DataSet.current_dataset(event_id, data_type)

		if dataset && !dataset.empty?
			return dataset.first.id
		else
			return nil
		end
	end

=begin
	def key_custom_children_shapes
		"custom_children_shapes/data_set_[data_set_id]/#{I18n.locale}/shape_[parent_shape_id]_indicator_[indicator_id]_shape_type_[shape_type_id]"
	end

	def key_summary_custom_children_shapes
		"summary_custom_children_shapes/data_set_[data_set_id]/#{I18n.locale}/shape_[parent_shape_id]_event_[event_id]_ind_type_[indicator_type_id]_shape_type_[shape_type_id]"
	end
=end
end
