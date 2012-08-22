class JsonController < ApplicationController
  layout false
	require 'json'

	#################################################
	##### shape jsons
	#################################################
  # GET /json/shape/:id/shape_type/:shape_type_id
  def shape
		geometries = Rails.cache.fetch("parent_shape_json_#{I18n.locale}_shape_#{params[:id]}") {
			Shape.build_json(params[:id], params[:shape_type_id]).to_json
		}

    respond_to do |format|
      format.json { render json: geometries }
    end
  end

  # GET /json/children_shapes/:parent_id/shape_type/:shape_type_id/event/:event_id(/parent_clickable/:parent_shape_clickable(/indicator/:indicator_id(/custom_view/:custom_view)))
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
				logger.debug "++++++++++event has custom shape, checking for file cache"
  			parent_shape = shape.ancestors.where(:shape_type_id => custom.first.shape_type_id)
  			custom_children_cache = nil
  			if !parent_shape.nil?
  				key = key_custom_children_shapes.gsub("[parent_shape_id]", parent_shape.first.id.to_s)
  				  .gsub("[indicator_id]", params[:indicator_id])
  				  .gsub("[shape_type_id]", params[:shape_type_id])
  				logger.debug "++++++++++custom children key = #{key}"
  				custom_children_cache = JsonCache.read(params[:event_id], key)
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
				geometries = Rails.cache.fetch("children_shapes_json_#{I18n.locale}_shape_#{params[:parent_id]}_parent_clickable_#{params[:parent_shape_clickable]}_indicator_#{params[:indicator_id]}_shape_type_#{params[:shape_type_id]}") {
					geo = ''

					if !params[:parent_shape_clickable].nil? && params[:parent_shape_clickable].to_s == "true"
						# get the parent shape and format for json
						geo = Shape.build_json(shape.id, shape.shape_type_id, params[:indicator_id]).to_json
					elsif shape.has_children?
						# get all of the children of the parent and format for json
						geo = Shape.build_json(shape.id, params[:shape_type_id], params[:indicator_id]).to_json
					end
				}
			end
		end

    respond_to do |format|
      format.json { render json: geometries}
    end
    logger.debug "@ time to render children_shapes json: #{Time.now-start} seconds"
  end

  # GET /json/custom_children_shapes/:parent_id/shape_type/:shape_type_id/event/:event_id/indicator/:indicator_id(/custom_view/:custom_view)
  def custom_children_shapes
    start = Time.now
		key = key_custom_children_shapes.gsub("[parent_shape_id]", params[:parent_id])
		  .gsub("[indicator_id]", params[:indicator_id])
		  .gsub("[shape_type_id]", params[:shape_type_id])
		geometries = JsonCache.fetch(params[:event_id], key) {
  		Shape.build_json(params[:parent_id], params[:shape_type_id], params[:indicator_id]).to_json
		}

		logger.debug "++++++++++custom children key = #{key}"
    respond_to do |format|
      format.json { render json: geometries}
    end
		logger.debug "@ time to render custom_children_shapes json from file: #{Time.now-start} seconds"
  end

	#################################################
	##### summary shape jsons
	#################################################
  # GET /json/summary_children_shapes/:parent_id/shape_type/:shape_type_id/event/:event_id/indicator_type/:indicator_type_id(/parent_clickable/:parent_shape_clickable(/custom_view/:custom_view))
  def summary_children_shapes
    start = Time.now
		geometries = nil
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
  			key = key_summary_custom_children_shapes.gsub("[parent_shape_id]", parent_shape.first.id.to_s)
  			  .gsub("[event_id]", params[:event_id])
  			  .gsub("[indicator_type_id]", params[:indicator_type_id])
  			  .gsub("[shape_type_id]", params[:shape_type_id])
  				logger.debug "++++++++++custom children key = #{key}"
  				custom_children_cache = JsonCache.read(params[:event_id], key)
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
				geometries = Rails.cache.fetch("summary_children_shapes_json_#{I18n.locale}_#{params[:parent_id]}_event_#{params[:event_id]}_ind_type_#{params[:indicator_type_id]}_parent_clickable_#{params[:parent_shape_clickable]}_shape_type_#{params[:shape_type_id]}") {
					geo = ''
					if !params[:parent_shape_clickable].nil? && params[:parent_shape_clickable].to_s == "true"
						# get the parent shape and format for json
						geo = Shape.build_summary_json(shape.id, shape.shape_type_id, params[:event_id], params[:indicator_type_id]).to_json
					elsif shape.has_children?
						# get all of the children of the parent and format for json
						geo = Shape.build_summary_json(shape.id, params[:shape_type_id], params[:event_id], params[:indicator_type_id]).to_json
					end
				}
			end
		end

    respond_to do |format|
      format.json { render json: geometries}
    end
    logger.debug "@ time to render summary_children_shapes json: #{Time.now-start} seconds"
  end


  # GET /json/summary_custom_children_shapes/:parent_id/shape_type/:shape_type_id/event/:event_id/indicator_type/:indicator_type_id(/custom_view/:custom_view)
  def summary_custom_children_shapes
    start = Time.now
		key = key_summary_custom_children_shapes.gsub("[parent_shape_id]", params[:parent_id])
		      .gsub("[event_id]", params[:event_id])
		      .gsub("[indicator_type_id]", params[:indicator_type_id])
		      .gsub("[shape_type_id]", params[:shape_type_id])
		geometries = JsonCache.fetch(params[:event_id], key) {
			#shapes = shape.subtree.where(:shape_type_id => params[:shape_type_id])
			geo = Shape.build_summary_json(params[:parent_id], params[:shape_type_id], params[:event_id], params[:indicator_type_id]).to_json
		}

    respond_to do |format|
      format.json { render json: geometries}
    end

    logger.debug "@ time to render summary_custom_children_shapes json from file: #{Time.now-start} seconds"
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



protected

	def key_custom_children_shapes
		"custom_children_shapes/#{I18n.locale}/shape_[parent_shape_id]_indicator_[indicator_id]_shape_type_[shape_type_id]"
	end

	def key_summary_custom_children_shapes
		"summary_custom_children_shapes/#{I18n.locale}/shape_[parent_shape_id]_event_[event_id]_ind_type_[indicator_type_id]_shape_type_[shape_type_id]"
	end
end
