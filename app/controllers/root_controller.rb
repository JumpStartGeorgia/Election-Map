# encoding: utf-8

class RootController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :shape, :children_shapes, :export, :download]
#	caches_action :shape, :children_shapes, :layout => false, :cache_path => Proc.new { |c| c.params }

  # GET /
  # GET /.json
	def index
		# get the event type id
		params[:event_type_id] = @event_types.first.id.to_s if params[:event_type_id].nil?
		
		# get the events for this event type
    @events = Event.get_events_by_type(params[:event_type_id])

    if !@events.nil? && @events.length > 0
  		# get the current event
  		event = get_current_event(params[:event_id])

			if !event.shape_id.nil?
				# get the shape
				params[:shape_id] = event.shape_id if params[:shape_id].nil?
		    logger.debug("shape id = #{params[:shape_id]}")
				@shape = Shape.get_shape_no_geometry(params[:shape_id])

				if !@shape.nil?
					# get the shape type id that was clicked
					params[:shape_type_id] = @shape.shape_type_id if params[:shape_type_id].nil?

					# now get the child shape type id
					parent_shape_type = get_shape_type(params[:shape_type_id])
					@child_shape_type_id = nil

          # if the parent shape is the root and the parent_shape_clickable is set to true,
          # make the parent shape also be the child shape
          if parent_shape_type.is_root? && !params[:parent_shape_clickable].nil? && params[:parent_shape_clickable].to_s == "true"
				    logger.debug("parent shape type is root and it should be clickable")
						child_shape_type = parent_shape_type
						@child_shape_type_id = child_shape_type.id
						# set the map title
						# format = parent shape type shape name
						@map_title = parent_shape_type.name_singular + ": " + @shape.common_name
					elsif !parent_shape_type.nil? && parent_shape_type.has_children?
				    logger.debug("parent shape type is not root or it should not be clickable")
					  # this is not the root, so reset parent shape clickable
					  params[:parent_shape_clickable] = false
						# found child, save id
						child_shape_type = get_child_shape_type(params[:shape_type_id])
						@child_shape_type_id = child_shape_type.id
						# set the map title
						# format = children shape types of parent shape type
						@map_title = parent_shape_type.name_singular + ": " + @shape.common_name + " - " + child_shape_type.name_plural
					end

					# get the indicators for the children shape_type
					if !params[:event_id].nil? && !@child_shape_type_id.nil?
						@indicators = Indicator.find_by_event_shape_type(params[:event_id],@child_shape_type_id)
					end

					# get the indicator
					# if the shape type changed, update the indicator_id to be valid for the new shape_type
					if !params[:indicator_id].nil?
						if !params[:change_shape_type].nil? && params[:change_shape_type] == "true"

							# we know the old indicator id and the new shape type
							# - use that to find the new indicator id
							new_indicator = Indicator.find_new_id(params[:indicator_id], @child_shape_type_id, params[:locale])
							if new_indicator.nil? || new_indicator.length == 0
								# could not find a match, reset the indicator id
								params[:indicator_id] = nil
							else
								# save the new value				
								params[:indicator_id] = new_indicator.first.id.to_s
								@indicator = new_indicator.first
							end
						else
							# get the selected indicator 
							@indicator = Indicator.find(params[:indicator_id])
						end
					end
				end
			end

  		# reset the parameter that indicates if the shape type changed
  		params[:change_shape_type] = false

  		# set js variables
      set_gon_variables

    else

    end

		render :layout => 'map'
	end

  # GET /events/shape/:id
  # GET /events/shape/:id.json
  def shape
		geometries = Rails.cache.fetch("shape_json_#{I18n.locale}_#{params[:id]}") {
			#get the parent shape
			shape = Shape.where(:id => params[:id])
			Shape.build_json(shape)
		}
    respond_to do |format|
      format.json { render json: geometries }
    end
  end

  # GET /events/children_shapes/:parent_id
  # GET /events/children_shapes/:parent_id.json
  def children_shapes
		geometries = Rails.cache.fetch("children_shapes_json_#{I18n.locale}_#{params[:parent_id]}_#{params[:parent_shape_clickable]}_#{params[:indicator_id]}") {
			geo = ''
			#get the parent shape
			shape = Shape.where(:id => params[:parent_id])

			if !shape.nil? && shape.length > 0
		    if !params[:parent_shape_clickable].nil? && params[:parent_shape_clickable].to_s == "true"
					# get the parent shape and format for json
					geo = Shape.build_json(shape, params[:indicator_id])
				elsif shape.first.has_children?
					# get all of the children of the parent and format for json
					geo = Shape.build_json(shape.first.children, params[:indicator_id])
				end
			end

			geo
		}
    respond_to do |format|
      format.json { render json: geometries}
    end
  end

  # POST /export
	# generate the svg file
  def export
		# create the file name: map title - indicator - event
		filename = params[:hidden_form_map_title].gsub(' ', '_')
		filename << "-"
		filename << params[:hidden_form_indicator_name_abbrv].gsub(' ', '_')
		filename << "-"
		filename << params[:hidden_form_event_name].gsub(' ', '_')

		headers['Content-Type'] = "image/svg+xml" 
    headers['Content-Disposition'] = "attachment; filename=\"#{filename}.svg\"" 
  end

  # GET /indicators/download
  # GET /indicators/download.json
  def download
		if !params[:event_id].nil? && !params[:shape_type_id].nil? && !params[:shape_id].nil?
      #get the data
      data = Datum.create_csv(params[:event_id], params[:shape_type_id], params[:shape_id], params[:indicator_id])

			if !data.nil && !data.csv_data.nil?
				# create file name using event name and map title that were passed in
				if params[:event_name].nil? || params[:map_title].nil?
			    filename = "data_download"
				else
			    filename = params[:map_title].gsub(' ', '_')
					filename << "-"
					filename << params[:event_name].gsub(' ', '_')

					#remove bad characters
					filename.gsub!(/[\\ \/ \: \* \? \" \< \> \| \, \. ]/,'')
				end
		    # send the file
		    send_data data.csv_data,
		      :type => 'text/csv; charset=utf-8; header=present',
		      :disposition => "attachment; filename=#{filename}.csv"
			end
		end
  end

  # GET /events/admin
  # GET /events/admin.json
  def admin

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @event }
    end
  end

  # GET /events/clear_cache
  def clear_cache
		Rails.cache.clear
  end

	# any mis-match routing errors are directed here
	def routing_error
		render_not_found(nil)
	end


private

	# get the the current event
	def get_current_event(event_id)
logger.debug "getting current event for id #{event_id}"
		if @events.nil? || @events.length == 0
logger.debug " - no events on record"
      return nil
    elsif event_id.nil?
logger.debug " - event id not provided, looking for first event"
      # no event selected yet, find first with a shape id
      @events.each do |e|
        if !e.shape_id.nil?
logger.debug " - found event, saving id"
        	# - save event_id 
          params[:event_id] = e.id.to_s
          return e
        end
      end
    else
logger.debug " - event id provided"
			@events.each do |event|
				if event.id.to_s == event_id.to_s
					# found match, return the hash
					return event
				end
			end
		end
	end

	# get the shape type
	def get_shape_type(shape_type_id)
		if @shape_types.nil? || @shape_types.length == 0 || shape_type_id.nil?
      return nil
    else
			@shape_types.each do |type|
				if type.id.to_s == shape_type_id.to_s
					# found match, return child
				  return type
				end
			end
		end
	end

	# get the child shape type
	def get_child_shape_type(parent_shape_type_id)
		if @shape_types.nil? || @shape_types.length == 0 || parent_shape_type_id.nil?
      return nil
    else
			@shape_types.each do |type|
				if type.id.to_s == parent_shape_type_id.to_s
					# found match, return child
					if type.has_children?
					  return type.children.first
					else
					  return nil
				  end
				end
			end
		end
	end

	
  def set_gon_variables
    # shape json paths
		# - only children shape path needs the indicator id since that is the only layer that is clickable
		if !params[:shape_id].nil?
			gon.shape_path = shape_path(:id => params[:shape_id])
			gon.children_shapes_path = children_shapes_path(:parent_id => params[:shape_id], 
			  :indicator_id => params[:indicator_id], :parent_shape_clickable => params[:parent_shape_clickable].to_s)
		end

		# indicator name
		if !@indicator.nil?
			gon.indicator_name = @indicator.name
			gon.indicator_name_abbrv = @indicator.name_abbrv
			gon.indicator_number_format = @indicator.number_format.nil? ? "" : @indicator.number_format
			gon.indicator_description = @indicator.description
			gon.indicator_scale_colors = IndicatorScale.get_colors(@indicator.id)
		end

		# indicator scales
		if !params[:indicator_id].nil?
			gon.showing_indicators = true
			build_indicator_scale_array
		else
			gon.showing_indicators = false
		end

    # save the map title for export
		if !params[:event_id].nil?
		  event = get_current_event(params[:event_id])
		  gon.event_id = event.id if !event.nil?
		  gon.event_name = event.name if !event.nil?
		  gon.map_title = @map_title
	  end
  end

  # build an array of indicator scales that will be used in js
  def build_indicator_scale_array
    if !params[:indicator_id].nil?
      # get the scales
      scales = IndicatorScale.find_by_indicator_id(params[:indicator_id])
      if !scales.nil? && scales.length > 0
        gon.indicator_scales = scales
      end
    end
  end



end
