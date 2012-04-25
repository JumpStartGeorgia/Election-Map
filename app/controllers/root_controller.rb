class RootController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :shape, :children_shapes, :export, :create_svg_file]

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
  		# - if no exist, get first event with shape
      params[:event_id] = event.id.to_s if params[:event_id].nil?

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
					if !parent_shape_type.nil? && parent_shape_type.has_children?
						# found child, save id
						child_shape_type = get_child_shape_type(params[:shape_type_id])
						@child_shape_type_id = child_shape_type.id
						# set the map title
						# format = children shape types of parent shape type
						@map_title = child_shape_type.name.pluralize + " of " + parent_shape_type.name + " " + @shape.common_name
					end

					# get the indicators for the children shape_type
					if !params[:event_id].nil? && !@child_shape_type_id.nil?
						@indicators = Indicator.where(:event_id => params[:event_id], :shape_type_id => @child_shape_type_id)
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
		#get the parent shape
		shape = Shape.where(:id => params[:id])
    respond_to do |format|
      format.json { render json: Shape.build_json(shape, params[:indicator_id]) }
    end
  end

  # GET /events/children_shapes/:parent_id
  # GET /events/children_shapes/:parent_id.json
  def children_shapes
		geometries = ''

		#get the parent shape
		shape = Shape.where(:id => params[:parent_id])

		if !shape.nil? && shape.length > 0 && shape.first.has_children?
			# get all of the children of the parent and format for json
			geometries = Shape.build_json(shape.first.children, params[:indicator_id])
		end

    respond_to do |format|
      format.json { render json: geometries}
    end
  end

  # POST /export
	# generate the svg file
  def export
		# create the file name: map title - indicator - event
		filename = params[:hidden_form_map_title].sub(' ', '_')
		filename << " - "
		filename << params[:hidden_form_indicator_name_abbrv].sub(' ', '_')
		filename << " - "
		filename << params[:hidden_form_event_name].sub(' ', '_')

		headers['Content-Type'] = "image/svg+xml" 
    headers['Content-Disposition'] = "attachment; filename=\"#{filename}.svg\"" 
  end

  # GET /events/admin
  # GET /events/admin.json
  def admin

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @event }
    end
  end

	# any mis-match routing errors are directed here
	def routing_error
		render_not_found(nil)
	end


private

	# get the default values for the provided event type
	def get_event_type_defaults(event_type_id)
		if @default_values.nil? || @default_values.length == 0 || event_type_id.nil?
      return nil
    else
			@default_values.each do |default|
				if default.event_type_id.to_s == event_type_id.to_s
					# found match, return the hash
					return default
				end
			end
		end
	end

	# get the the current event
	def get_current_event(event_id)
		if @events.nil? || @events.length == 0
      return nil
    elsif event_id.nil?
      # no event select yet, find first with a shape id
      @events.each do |e|
        if !e.shape_id.nil?
          return e
        end
      end
    else
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
		# - only chilrend shape path needs the indicator id since that is the only layer that is clickable
		if !params[:shape_id].nil?
			gon.shape_path = shape_path(:id => params[:shape_id])
			gon.children_shapes_path = children_shapes_path(:parent_id => params[:shape_id], :indicator_id => params[:indicator_id])
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
		  gon.event_name = event.name if !event.nil?
		  gon.map_title = @map_title
	  end
  end

  # build an array of indicator scales that will be used in js
  def build_indicator_scale_array
    if !params[:indicator_id].nil?
      # get the scales
      scales = IndicatorScale.where(:indicator_id => params[:indicator_id])
      if !scales.nil? && scales.length > 0
        gon.indicator_scales = scales
      end
    end
  end



end
