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
					    d = Datum.build_json(shape.id, shape.shape_type_id, params[:indicator_id], params[:data_set_id]).to_json
				    elsif shape.has_children?
					    d = Datum.build_json(shape.id, params[:shape_type_id], params[:indicator_id], params[:data_set_id]).to_json
				    end
				    d
			    }
=end
          if !params[:parent_shape_clickable].nil? && params[:parent_shape_clickable].to_s == "true"
	          data = Datum.build_json(shape.id, shape.shape_type_id, params[:indicator_id], params[:data_set_id]).to_json
          elsif shape.has_children?
	          data = Datum.build_json(shape.id, params[:shape_type_id], params[:indicator_id], params[:data_set_id]).to_json
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
			  Datum.build_json(params[:parent_id], params[:shape_type_id], params[:indicator_id], params[:data_set_id]).to_json
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
						  d = Datum.build_summary_json(shape.id, shape.shape_type_id, params[:event_id], params[:indicator_type_id], params[:data_set_id]).to_json
					  elsif shape.has_children?
  logger.debug "++++++++++++++++++++++++++++ getting summary with NO parent shape clickable"
						  d = Datum.build_summary_json(shape.id, params[:shape_type_id], params[:event_id], params[:indicator_type_id], params[:data_set_id]).to_json
					  end
					  d
				  }
=end
          if !params[:parent_shape_clickable].nil? && params[:parent_shape_clickable].to_s == "true"
	          data = Datum.build_summary_json(shape.id, shape.shape_type_id, params[:event_id], params[:indicator_type_id], params[:data_set_id]).to_json
          elsif shape.has_children?
	          data = Datum.build_summary_json(shape.id, params[:shape_type_id], params[:event_id], params[:indicator_type_id], params[:data_set_id]).to_json
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
			  Datum.build_summary_json(params[:parent_id], params[:shape_type_id], params[:event_id], params[:indicator_type_id], params[:data_set_id]).to_json
		  }
    end

    respond_to do |format|
      format.json { render json: data}
    end

    logger.debug "@ time to render summary_custom_children_data json: #{Time.now-start} seconds"
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

	def key_custom_children_shapes
		"custom_children_shapes/data_set_[data_set_id]/#{I18n.locale}/shape_[parent_shape_id]_indicator_[indicator_id]_shape_type_[shape_type_id]"
	end

	def key_summary_custom_children_shapes
		"summary_custom_children_shapes/data_set_[data_set_id]/#{I18n.locale}/shape_[parent_shape_id]_event_[event_id]_ind_type_[indicator_type_id]_shape_type_[shape_type_id]"
	end
end
