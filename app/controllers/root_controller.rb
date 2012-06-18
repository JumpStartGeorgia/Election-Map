# encoding: utf-8
#require 'csv_tsv_renderer'

class RootController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :shape, :children_shapes, :grandchildren_shapes, :export, :download]
#	caches_action :shape, :children_shapes, :layout => false, :cache_path => Proc.new { |c| c.params }

  # GET /
  # GET /.json
	def index
		# set flag indicating that a param is missing or data could not be found
		# which will cause user to go back to home page
		flag_redirect = false

		# get the event type id
		params[:event_type_id] = @event_types.first.id.to_s if params[:event_type_id].nil?
		
		# get the events for this event type
    @events = Event.get_events_by_type(params[:event_type_id])

		if @events.nil? || @events.empty?
			# no events could be found
logger.debug "+++++++++ no events could be found"
			flag_redirect = true
		else
  		# get the current event
  		event = get_current_event(params[:event_id])

			if event.nil? || event.shape_id.nil?
				# event could not be found or the selected event does not have a shape assigned to it
logger.debug "+++++++++ event could not be found or the selected event does not have a shape assigned to it"
				flag_redirect = true
			else
				# get the shape
				params[:shape_id] = event.shape_id if params[:shape_id].nil?
		    logger.debug("shape id = #{params[:shape_id]}")
				@shape = Shape.get_shape_no_geometry(params[:shape_id])

				if @shape.nil?
					# parent shape could not be found
logger.debug "+++++++++ parent shape could not be found"
					flag_redirect = true
				else
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
					  params[:parent_shape_clickable] = nil
						# found child, save id
#						child_shape_type = get_child_shape_type(params[:shape_type_id])
						child_shape_type = get_child_shape_type(@shape)
						@child_shape_type_id = child_shape_type.id
						# set the map title
						# format = children shape types of parent shape type
						@map_title = parent_shape_type.name_singular + ": " + @shape.common_name + " - " + child_shape_type.name_plural
					end

					# get the indicators for the children shape_type
					if !params[:event_id].nil? && !@child_shape_type_id.nil?
						@indicator_types = IndicatorType.find_by_event_shape_type(params[:event_id], @child_shape_type_id)
					end

					if @indicator_types.nil? || @indicator_types.empty?
						# no indicators exist for this event and shape type
logger.debug "+++++++++ no indicators exist for this event and shape type"
						flag_redirect = true
					else
						# if an indicator is not selected, select the first one in the list
						if params[:indicator_id].nil?
							params[:indicator_id] = @indicator_types[0].indicators[0].id if !@indicator_types[0].indicators.nil? && !@indicator_types[0].indicators.empty?
						end

						# get the indicator
						# if the shape type changed, update the indicator_id to be valid for the new shape_type
						if !params[:change_shape_type].nil? && params[:change_shape_type] == "true"

							# we know the old indicator id and the new shape type
							# - use that to find the new indicator id
							new_indicator = Indicator.find_new_id(params[:indicator_id], @child_shape_type_id)
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
  		params[:change_shape_type] = nil

  		# set js variables
      set_gon_variables
    end

    if flag_redirect
			# either data could not be found or param is missing and page could not be loaded
logger.debug "+++++++++ either data could not be found or param is missing and page could not be loaded, redirecting to home page"
			redirect_to root_path
		else
			render :layout => 'map'
		end
	end

  # GET /events/shape/:id
  # GET /events/shape/:id.json
  def shape
		geometries = Rails.cache.fetch("shape_json_#{I18n.locale}_#{params[:id]}") {
			#get the parent shape
			shape = Shape.where(:id => params[:id])
			Shape.build_json(shape)
		}
=begin
    #get the parent shape
    shape = Shape.where(:id => params[:id])
    geometries = Shape.build_json(shape)
=end
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
=begin
    geometries = nil
    #get the parent shape
    shape = Shape.where(:id => params[:parent_id])

    if !shape.nil? && shape.length > 0
      if !params[:parent_shape_clickable].nil? && params[:parent_shape_clickable].to_s == "true"
    		# get the parent shape and format for json
    		geometries = Shape.build_json(shape, params[:indicator_id])
    	elsif shape.first.has_children?
    		# get all of the children of the parent and format for json
    		geometries = Shape.build_json(shape.first.children, params[:indicator_id])
    	end
    end
=end
    respond_to do |format|
      format.json { render json: geometries}
    end
  end

  # GET /events/grandchildren_shapes/:parent_id
  # GET /events/grandchildren_shapes/:parent_id.json
  def grandchildren_shapes

		geometries = Rails.cache.fetch("grandchildren_shapes_json_#{I18n.locale}_#{params[:parent_id]}_#{params[:parent_shape_clickable]}_#{params[:indicator_id]}") {
			geo = ''
			#get the parent shape
			shape = Shape.where(:id => params[:parent_id])

		  if !shape.nil? && shape.length > 0
		    if !params[:parent_shape_clickable].nil? && params[:parent_shape_clickable].to_s == "true"
		  		# get the parent shape and format for json
		  		geo = Shape.build_json(shape, params[:indicator_id])
		  	elsif shape.first.has_children?
		  		# get all of the grandchildren of the parent, and format for json
					shapes = []
					shape.first.children.each do |child|
						if child.has_children?
							shapes << child.children
						end
					end
					# flatten all of the nested arrays into just one array
					shapes.flatten!
		  		geo = Shape.build_json(shapes, params[:indicator_id])
		  	end
		  end

			geo
		}

=begin
    geometries = nil
    #get the parent shape
    shape = Shape.where(:id => params[:parent_id])

    if !shape.nil? && shape.length > 0
      if !params[:parent_shape_clickable].nil? && params[:parent_shape_clickable].to_s == "true"
    		# get the parent shape and format for json
    		geometries = Shape.build_json(shape, params[:indicator_id])
    	elsif shape.first.has_children?
    		# get all of the grandchildren of the parent, and format for json
				shapes = []
				shape.first.children.each do |child|
					if child.has_children?
						shapes << child.children
					end
				end
				# flatten all of the nested arrays into just one array
				shapes.flatten!
    		geometries = Shape.build_json(shapes, params[:indicator_id])
    	end
    end
=end
    respond_to do |format|
      format.json { render json: geometries}
    end
  end

  # POST /export
	# generate the svg file
  def export
		# cannot use georgian characters in file name
		if I18n.locale.to_s == "ka"
	    filename = "election_map_svg"
		else
			# create the file name: map title - indicator - event
			filename = params[:hidden_form_map_title]
			filename << "-"
			filename << params[:hidden_form_indicator_name_abbrv]
			filename << "-"
			filename << params[:hidden_form_event_name]
		end
			filename << "-#{l Time.now, :format => :file}"

		headers['Content-Type'] = "image/svg+xml; charset=utf-8" 
    headers['Content-Disposition'] = "attachment; filename=#{clean_filename(filename)}.svg" 
  end

  # GET /indicators/download
  # GET /indicators/download.json
  def download
		if !params[:event_id].nil? && !params[:shape_type_id].nil? && !params[:shape_id].nil?
      #get the data
      data = Datum.create_csv(params[:event_id], params[:shape_type_id], params[:shape_id], params[:indicator_id])

			if !data.nil && !data.csv_data.nil?
				# create file name using event name and map title that were passed in
				# cannot use georgian characters in file name
				if I18n.locale.to_s == "ka" || params[:event_name].nil? || params[:map_title].nil?
			    filename = "election_map_data"
				else
			    filename = params[:map_title]
					filename << "-"
					filename << params[:event_name]
				end
				filename << "-#{l Time.now, :format => :file}"

		    # send the file
		    send_data data.csv_data,
		      :type => 'text/tab-separated-values; header=present',
		      :disposition => "attachment; filename=#{clean_filename(filename)}.csv"
			end

=begin
# code for testing csv download that works in excel
      data = Datum.test_csv(params[:event_id], params[:shape_type_id], params[:shape_id], params[:indicator_id])
		  respond_to do |format|
				format.csv  { send_data data.to_csv(), :filename => "nice_filename.csv" }
				format.tsv  { send_data data.to_tsv(), :filename => "nice_filename.tsv" }
		  end
=end
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
		if @events.nil? || @events.empty?
logger.debug " - no events on record"
      return nil
    elsif event_id.nil?
logger.debug " - event id not provided, looking for first event"
      # no event selected yet, find first with a shape id
      @events.each do |e|
        if !e.shape_id.nil?
logger.debug " - found event, saving id"
        	# - save event_id 
          params[:event_id] = e.id
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
			# if get to here then no matching event was found
logger.debug " - no matching event found!"
			return nil
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

	# get the child shape type of the current shape
	def get_child_shape_type(shape)
		if shape.nil?
      return nil
    else
      if shape.has_children?
        # shape has children, get the shape type of children
        return shape.children.first.shape_type
      else
        return nil
      end
		end
	end

	# get the child shape type
	def get_child_shape_type_old(parent_shape_type_id)
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
			gon.indicator_description = @indicator.description
			gon.indicator_number_format = @indicator.number_format.nil? ? "" : @indicator.number_format
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
