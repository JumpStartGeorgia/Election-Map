class RootController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :shape, :children_shapes, :export, :create_svg_file]

  # GET /export
  # read the svg file into the svg erb file
  def export
    @svg_map = ""
		if !params[:datetime].nil?
	    File.open("#{@svg_directory_path}#{params[:datetime]}.svg","r").each {|line| @svg_map << line }
		end
  end

  # POST /create_svg_file
  # the export link will post to this action and the svg layers will be written to file
	def create_svg_file
		if (!params[:parent_layer].nil? && !params[:child_layer].nil? && !params[:datetime].nil?)
			#house cleaning - remove files older than 2 days
			Dir.glob("#{@svg_directory_path}*.svg"){ |name| 
				file = File.new(name)
				if file.mtime < 1.minute.ago
					File.delete(name)
				end
				file.close
			}

			# write the svg data into the new svg file
			svg_file = File.new("#{@svg_directory_path}#{params[:datetime]}.svg","w")
		  # parse the svg info to remove the xml and svg tag
		  data = Nokogiri::XML(params[:parent_layer])
		  svg_file.puts(data.children().children())

		  data = Nokogiri::XML(params[:child_layer])
		  svg_file.puts(data.children().children())

			svg_file.close

		end
		render :nothing => true						  
	end	

  # GET /
  # GET /.json
	def index
		# get the event type id
		params[:event_type_id] = @event_types.first.id.to_s if params[:event_type_id].nil?
		
		# get default values for this event type
		@default_values = get_event_type_defaults(params[:event_type_id])
		if @default_values.nil?
#TODO - do what?
		end

		# get the events for this event type
		@events = Event.where(:event_type_id => params[:event_type_id])

		# get the current event
		params[:event_id] = @default_values.event_id.to_s	if params[:event_id].nil?

		# get the shape
		params[:shape_id] = @default_values.shape_id if params[:shape_id].nil?
		@shape = Shape.get_shape_no_geometry(params[:shape_id])

		# get the shape type id that was clicked
		params[:shape_type_id] = @default_values.shape_type_id if params[:shape_type_id].nil?
		
		# now get the child shape type id
		parent_shape_type = get_shape_type(params[:shape_type_id])
		@child_shape_type_id = nil
		if (!parent_shape_type.nil? && parent_shape_type.has_children?)
			# found child, save id
			child_shape_type = get_child_shape_type(params[:shape_type_id])
			@child_shape_type_id = child_shape_type.id
			# set the map title
			# format = children shape types of parent shape type
			@map_title = child_shape_type.name.pluralize + " of " + parent_shape_type.name + " " + @shape.common_id
		end

		# get the indicators for the children shape_type
		if !params[:event_id].nil? && !@child_shape_type_id.nil?
			@indicators = Indicator.where(:event_id => params[:event_id], :shape_type_id => @child_shape_type_id)
		end

		# get the indicator
		# if the shape type changed, update the indicator_id to be valid for the new shape_type
		if !params[:indicator_id].nil?
			if !params[:change_shape_type].nil? && params[:change_shape_type] == "true"
logger.debug "+++++ old indicator id = #{params[:indicator_id]}"

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
logger.debug "++++++ new indicator id = #{params[:indicator_id]}"
			else
				# get the selected indicator 
				@indicator = Indicator.find(params[:indicator_id])
			end
		end

		# reset the parameter that indicates if the shape type changed
		params[:change_shape_type] = false

		# set js variables
    set_gon_variables
    
		render :layout => 'map'
	end

  # GET /events/shape/:id
  # GET /events/shape/:id.json
  def shape
		#get the parent shape
logger.debug("indicator id = #{params[:indicator_id]}")
		shape = Shape.where(:id => params[:id])
    respond_to do |format|
      format.json { render json: Shape.build_json(shape, params[:indicator_id]) }
    end
  end

  # GET /events/children_shapes/:parent_id
  # GET /events/children_shapes/:parent_id.json
  def children_shapes
logger.debug("indicator id = #{params[:indicator_id]}")
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

  # GET /events/admin
  # GET /events/admin.json
  def admin

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @event }
    end
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
	def get_event(event_id)
		if @events.nil? || @events.length == 0 || event_id.nil?
      return nil
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
    if params[:shape_id].nil?
      # shape id is not provided, find the shape assigned to the event
  		event = nil
  		if !params[:event_id].nil?
    		@events.each do |ev|
    			if ev.id.to_s == params[:event_id]
    				event = ev 
    				break
    			end
    		end
    		if event.nil? || event.shape_id.nil?
    			# set default
          # no event selected or event does not have a shape assigned to it, using defaults for gon variables
    			gon.shape_path = shape_path(:id => @default_values.shape_id)
    			gon.children_shapes_path = children_shapes_path(:parent_id => @default_values.shape_id, :indicator_id => params[:indicator_id])
    		else
    		  # found event, load its shape
    			gon.shape_path = shape_path(:id => event.shape_id)
    			gon.children_shapes_path = children_shapes_path(:parent_id => event.shape_id, :indicator_id => params[:indicator_id])
    		end
      else
        # no event selected yet, use default shape
  			gon.shape_path = shape_path(:id => @default_values.shape_id)
  			gon.children_shapes_path = children_shapes_path(:parent_id => @default_values.shape_id, :indicator_id => params[:indicator_id])
      end
    else
      # shape id is provided, use it
			gon.shape_path = shape_path(:id => params[:shape_id])
			gon.children_shapes_path = children_shapes_path(:parent_id => params[:shape_id], :indicator_id => params[:indicator_id])
    end

		# indicator name
		if !@indicator.nil?
			gon.indicator_name = @indicator.name
			gon.indicator_name_abbrv = @indicator.name_abbrv
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
    # format: indicator for event in shape
    gon.map_title = ""
    gon.map_title << "#{@indicator.name} for " if !@indicator.nil? 
    event = get_event(params[:event_id])
    gon.map_title << "#{event.name} in " if !event.nil?
    gon.map_title << @map_title
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
