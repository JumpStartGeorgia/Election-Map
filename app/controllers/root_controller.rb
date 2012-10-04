# encoding: utf-8
class RootController < ApplicationController
  before_filter :authenticate_user!,
    :except => [:index, :export, :download, :data_table]
	require 'ostruct'
  require 'data_archive'

  # GET /
  # GET /.json
	def index
		# set flag indicating that a param is missing or data could not be found
		# which will cause user to go back to home page
		flag_redirect = false

		# get the event type id
    if params[:event_type_id].nil? && @event_types.empty?
logger.debug "////////////// event type id does not exist and no event types with public events exist"
# TODO - what to do?
    end
logger.debug "////////////// getting event type id"
		if params[:event_type_id].nil?
			set_default_event_params
			# if no default event exists, just resort to first event type in list
			params[:event_type_id] = @event_types.first.id.to_s if params[:event_type_id].nil?
		end

		# get the current event
logger.debug "////////////// getting current event for event type #{params[:event_type_id]}"
		event = get_current_event(params[:event_type_id], params[:data_type], params[:event_id])

		if event.nil? || event.shape_id.nil?
			# event could not be found or the selected event does not have a shape assigned to it
			logger.debug "+++++++++ event could not be found or the selected event does not have a shape assigned to it"

			# if this is a live event, mark flag to show user message that data does not exist yet and to come back
      live_event = @live_event_menu.select{|x| x["id"].to_s == params["event_id"].to_s}
			if params[:data_type] == Datum::DATA_TYPE[:live] && live_event && !live_event.empty?
			  logger.debug "+++++++++ this is live event but no data has been loaded yet"
        @live_event_with_no_data = true
        @live_event_name = live_event.first["name"]
        @live_event_data_available = live_event.first["data_available_at"]
        @live_event_data_available_est = live_event.first["data_available_at"].in_time_zone('Eastern Time (US & Canada)')
        @page_title = "#{@live_event_name} - #{l(@live_event_data_available, :format => :default_no_tz)}".html_safe
        gon.live_event_with_no_data = true
        gon.live_event_time_to_data = countdown_duration(Time.now, live_event.first["data_available_at"])
      else
			  flag_redirect = true
      end
		else
			# save the event name
			@event_name = event.name
			@event_description = event.description

  		# get data set info
			dataset = DataSet.find(params[:data_set_id]) if params[:data_set_id] && !params[:data_set_id].empty?

			# get the most recent dataset for this event
      most_recent_dataset = DataSet.current_dataset(event.id, params[:data_type])
			@most_recent_dataset = most_recent_dataset.first if most_recent_dataset
			dataset = @most_recent_dataset if !dataset

      if dataset
        params[:data_set_id] = dataset.id.to_s
		    @live_event_precincts_percentage = dataset.precincts_percentage
		    @live_event_precincts_completed = dataset.precincts_completed
		    @live_event_precincts_total = dataset.precincts_total
		    @live_event_timestamp = dataset.timestamp

				# if the most_recent_datset > passed in dataset,
				# tell user that newer data is available
				@newer_data_available = @most_recent_dataset.id > dataset.id ? true : false if @most_recent_dataset
		  else
  			# dataset could not be found for event
  			logger.debug "+++++++++ an public data set could not be found for event"
  			flag_redirect = true
	    end

      if !flag_redirect
  			# get the shape
  logger.debug "////////////// getting shape"
  			params[:shape_id] = event.shape_id if params[:shape_id].nil?
  			logger.debug("+++++++++shape id = #{params[:shape_id]}")
  			@shape = Shape.get_shape_no_geometry(params[:shape_id])

  			if @shape.nil?
  				# parent shape could not be found
  				logger.debug "+++++++++ parent shape could not be found"
  				flag_redirect = true
  			else
  				# get the shape type id that was clicked
  				params[:shape_type_id] = @shape.shape_type_id if params[:shape_type_id].nil?

  				# now get the child shape type id
  logger.debug "////////////// getting parent shape type"
  				parent_shape_type = get_shape_type(params[:shape_type_id])
  				@child_shape_type_id = nil

  				if parent_shape_type.nil?
  					logger.debug("+++++++++ parent shape type could not be found")
  					flag_redirect = true
  				else
  logger.debug "////////////// getting event custom view"
  					# if the event has a custom view for the parent shape type, use it
  					custom_view = event.event_custom_views.where(:shape_type_id => parent_shape_type.id).with_translations(I18n.locale)
  					@is_custom_view = false
  					@has_custom_view = false
  					if !custom_view.nil? && !custom_view.empty? && (params[:parent_shape_clickable].nil? || params[:parent_shape_clickable].to_s != "true")
  logger.debug "////////////// has custom view"
  						@has_custom_view = true
  						# set the param if not set yet
  						params[:custom_view] = custom_view.first.is_default_view.to_s if params[:custom_view].nil?

  						if params[:custom_view] == "true"
  							logger.debug("+++++++++ parent shape type has custom view of seeing shape_type #{custom_view.first.descendant_shape_type_id} ")
  							#found custom view, use it to get the child shape type
  							child_shape_type = custom_view.first.descendant_shape_type
  							custom_child_shape_type = get_child_shape_type(@shape)
  							# indicate custom view is being used
  							@is_custom_view = true
  							# save the note for this custom view
  							@custom_view_note = custom_view.first.note
  						else
  							logger.debug("+++++++++ parent shape type has custom view, but not using it")
  							child_shape_type = get_child_shape_type(@shape)
  							custom_child_shape_type = custom_view.first.descendant_shape_type
  						end
  					elsif parent_shape_type.is_root? && !params[:parent_shape_clickable].nil? && params[:parent_shape_clickable].to_s == "true"
  			      # if the parent shape is the root and the parent_shape_clickable is set to true,
  			      # make the parent shape also be the child shape
  logger.debug "////////////// child shape type = parent"
  						logger.debug("+++++++++ parent shape type is root and it should be clickable")
  						child_shape_type = parent_shape_type.clone
  					elsif parent_shape_type.has_children?
  logger.debug "////////////// getting child shape type"
  						logger.debug("+++++++++ parent shape type is not root or it should not be clickable")
  						# this is not the root, so reset parent shape clickable
  						params[:parent_shape_clickable] = nil
  #						child_shape_type = get_child_shape_type(params[:shape_type_id])
  						child_shape_type = get_child_shape_type(@shape)
  					else
  						logger.debug("+++++++++ parent shape type is not root and parent shape type does not have children")
  						flag_redirect = true
  					end

  					if !flag_redirect
  logger.debug "////////////// setting @ variables"
              @parent_shape_type = parent_shape_type.id
  						@parent_shape_type_name_singular = parent_shape_type.name_singular
  						@child_shape_type_id = child_shape_type.id
  						@child_shape_type_name_singular_possessive = child_shape_type.name_singular_possessive
  						@child_shape_type_name_plural = child_shape_type.name_plural
  						if @has_custom_view
  							@custom_child_shape_type_name_singular = custom_child_shape_type.name_singular
  							if I18n.locale == :ka
  								@custom_child_shape_type_name_plural = custom_child_shape_type.name_singular
  							else
  								@custom_child_shape_type_name_plural = custom_child_shape_type.name_plural
  							end
  						end
  						@map_title = nil
  						# set the map title
  						if parent_shape_type.id == child_shape_type.id
  							@map_title = @parent_shape_type_name_singular + ": " + @shape.common_name
  						else
  							@map_title = @parent_shape_type_name_singular + ": " + @shape.common_name + " - " + @child_shape_type_name_plural
  						end
							# if this is live data, add the precincts reported numbers
							if params[:data_type] == Datum::DATA_TYPE[:live]
								precincts_reporting = Datum.get_precincts_reported(params[:shape_id], params[:event_id], params[:data_set_id])
								if precincts_reporting && !precincts_reporting.empty?
									if @show_precinct_percentages
										@map_title_precincts = I18n.t('app.common.live_event_status',
																		:completed => precincts_reporting[:completed_number],
			                              :total => precincts_reporting[:num_precincts],
			                              :percentage => precincts_reporting[:completed_percent])
									else
										@map_title_precincts = I18n.t('app.common.live_event_status_no_percent',
																		:completed => precincts_reporting[:completed_number])
									end
								end
							end
  logger.debug "////////////// done setting @ variables"
  					end

  				end

  				if @child_shape_type_id.nil? || flag_redirect
  					logger.debug("+++++++++ child shape type could not be found")
  					flag_redirect = true
  				else
  logger.debug "////////////// getting indicators"
  					# get the indicators for the children shape_type
  					@indicator_types = IndicatorType.find_by_event_shape_type(params[:event_id], @child_shape_type_id)

  					if @indicator_types.nil? || @indicator_types.empty?
  						# no indicators exist for this event and shape type
  						logger.debug "+++++++++ no indicators exist for this event and shape type"
  						flag_redirect = true
  					else
  						# if an indicator is not selected, select the first one in the list
  						# if the first indicator type has a summary, select the summary
  						if params[:indicator_id].nil? && params[:view_type].nil?
  logger.debug "////////////// selecting first indicator"
								x = get_current_indicator(@indicator_types)
								if x[:error]
  								logger.debug "+++++++++ cound not find an indicator to set as the value for params[:indicator_id]"
									flag_redirect = true
								elsif x[:view_type] == @summary_view_type_name
logger.debug "////////////// - default is summary"
									# first indicator is summary
									params[:view_type] = x[:view_type]
									params[:indicator_type_id] = x[:indicator_type_id]
								elsif x[:indicator_id]
logger.debug "////////////// - default is indicator, getting record"
									params[:indicator_type_id] = x[:indicator_type_id]
									params[:indicator_id] = x[:indicator_id]
								else
logger.debug "////////////// - no default found"
  								logger.debug "+++++++++ cound not find an indicator to set as the value for params[:indicator_id]"
									flag_redirect = true
								end

=begin
  							if @indicator_types[0].has_summary
  								params[:view_type] = @summary_view_type_name
  								params[:indicator_type_id] = @indicator_types[0].id
  							elsif @indicator_types[0].core_indicators.nil? || @indicator_types[0].core_indicators.empty? ||
  										@indicator_types[0].core_indicators[0].indicators.nil? ||
  										@indicator_types[0].core_indicators[0].indicators.empty?
  								# could not find an indicator
  								logger.debug "+++++++++ cound not find an indicator to set as the value for params[:indicator_id]"
  								flag_redirect = true
  							else
  								params[:indicator_id] = @indicator_types[0].core_indicators[0].indicators[0].id
  								params[:indicator_type_id] = @indicator_types[0].id
  							end
=end
  						end
  						# get the indicator
  						# if the shape type changed, update the indicator_id to be valid for the new shape_type
  						# only if this is not the summary view
  	          if params[:view_type] != @summary_view_type_name
  logger.debug "////////////// getting the current indicator"
  							if !params[:change_shape_type].nil? && params[:change_shape_type] == "true"
  logger.debug "////////////// this is shape change - getting indicator at new shape level"
  								# we know the old indicator id and the new shape type
  								# - use that to find the new indicator id
  								new_indicator = Indicator.find_new_id(params[:indicator_id], @child_shape_type_id)
  								if new_indicator.nil?
  logger.debug "////////////// - could not find new indicator, looking for default"
										# could not find matching indicator at new level
										# - so now use first indicator in list
										x = get_current_indicator(@indicator_types)
										if x[:error]
											logger.debug "+++++++++ cound not find matching indicator at new shape level and could not find default indicator"
											flag_redirect = true
										elsif x[:view_type] == @summary_view_type_name
  logger.debug "////////////// - default is summary"
											# first indicator is summary
											params[:view_type] = x[:view_type]
											params[:indicator_type_id] = x[:indicator_type_id]
											no_match_indicator_using_summary = true
										elsif x[:indicator_id]
  logger.debug "////////////// - default is indicator, getting record"
											params[:indicator_type_id] = x[:indicator_type_id]
											params[:indicator_id] = x[:indicator_id]
		  								@indicator = Indicator.find(params[:indicator_id])
										else
  logger.debug "////////////// - no default found"
											# could not find a match, reset the indicator id
											params[:indicator_id] = nil
										end
  								else
  logger.debug "////////////// - found new indicator, saving"
  									# save the new value
  									params[:indicator_id] = new_indicator.id.to_s
  									@indicator = new_indicator
  								end
  							else
  logger.debug "////////////// - getting indicator using id passed in"
  								# get the selected indicator
  								@indicator = Indicator.find(params[:indicator_id])
  logger.debug "////////////// -- indicator = #{@indicator.inspect}"
  							end
  							if @indicator
    							# save the indicator type id so the indicator menu works
    							params[:indicator_type_id] = @indicator.core_indicator.indicator_type_id if params[:indicator_type_id].nil?
							  elsif !no_match_indicator_using_summary
  								# could not find an indicator
  								logger.debug "+++++++++ cound not find the desired indicator"
  								flag_redirect = true
						    end
  logger.debug "////////////// done getting current indicator"
  						end

  						# if have custom view, get indicator if user wants to switch between custom view and non-custom view
  						if !flag_redirect && @has_custom_view
  logger.debug "////////////// is custom view, getting indicator to switch between views"
  							@custom_indicator_id = nil

  							custom_indicator = Indicator.find_new_id(params[:indicator_id], custom_child_shape_type.id)
  							if !custom_indicator.nil?
  								@custom_indicator_id = custom_indicator.id.to_s
  							end
  						end
  					end
  				end
  			end

      end
		end

    # create the page title
    if @map_title && @event_name
      if params[:view_type] == @summary_view_type_name && @indicator_types && !@indicator_types.empty?
        @page_title = "#{@event_name} > #{@indicator_types[0].summary_name} > #{@map_title}".html_safe
      elsif @indicator
        @page_title = "#{@event_name} > #{@indicator.name_abbrv_w_parent} > #{@map_title}".html_safe
      end
    end

		# reset the parameter that indicates if the shape type changed
		params[:change_shape_type] = nil

		# set js variables
logger.debug "////////////// setting gon variables"
    set_gon_variables if !flag_redirect && !@live_event_with_no_data

logger.debug "//////////////////////////////////////////////////////// done with index action"

    if flag_redirect
			# either data could not be found or param is missing and page could not be loaded
			logger.debug "+++++++++ either data could not be found or param is missing and page could not be loaded, redirecting to home page"
			redirect_to root_path
		end
	end

  def data_table
    child_shape_type_id = params[:child_shape_type_id]
    summary_view_type_name = params[:summary_view_type_name]
    params[:custom_view] = params[:custom_view].nil? ? false : params[:custom_view]

		# if data type is live, the dataset must also be provided
		params_ok = true
		if params[:data_type] == Datum::DATA_TYPE[:live] && !(params[:data_set_id] && !params[:data_set_id].empty?)
			params_ok = false
		end

		if params_ok
			# get the data
		  get_data = Datum.get_table_data(params[:event_id], params[:data_set_id], child_shape_type_id, params[:shape_id])

			if !get_data.nil? && !get_data.empty? && get_data[:data] && !get_data[:data].empty?
				dt = OpenStruct.new(
				  'cols_p'             => 7, #data columns count per turn
				  'skip_cols'          => 3, #data columns skip count, e.g. ["Event", " Map Level", " District ID"]
				  'static_cols'        => 1, #data static columns count, e.g. "District name"

				  'data'               => get_data[:data],
				  'indicator_ids'      => get_data[:indicator_ids],
				  'indicator_type_ids' => get_data[:indicator_type_ids],
				  'dd_titles'          => []
				)
				s = dt.skip_cols + dt.static_cols
				dt.indicator_ids = [0] * dt.static_cols + dt.indicator_ids[s..- 1]
				dt.data.each_with_index do |val, i|
				  dt.data[i] = dt.data[i][dt.skip_cols..- 1]
				end

				# selected indicator id
				if params[:indicator_id].nil? || params[:indicator_id] == 'null'
				  if params[:view_type] == summary_view_type_name
				    dt.sid = 'winner_ind'
				  else
				    dt.sid = ''
				  end
				else
				  dt.sid = params[:indicator_id]
				end
				dt.sid = dt.sid.to_s

				dt_count = dt.data[0].count
				# column groups count
				#dt.groups = ((dt_count - dt.skip_cols).to_f / (dt.cols_p - dt.static_cols)).ceil
				#c = dt.cols_p - dt.static_cols
				# dropdown titles
				#dt.groups.times do |i|
				#  dt.dd_titles << dt.data[0][dt.static_cols..- 1][(c * i)..(c * (i + 1) - 1)]
				#end
				dt.groups = ((dt_count - dt.static_cols).to_f / (dt.cols_p - dt.static_cols)).ceil
				dt.dd_titles = dt.data[0][dt.static_cols..-1]
				dt.gon = {:dt => {:g => dt.groups, :p => dt.cols_p, :all => dt.data[0].count}}
				dt.gon[:dt][:common_name] = params[:highlight_shape].nil? ? false : params[:highlight_shape]
				@dt = dt

			end
		end

    render :layout => 'ajax_data_table'
  end

  # POST /export
	# generate the svg file
  def export
		# create the file name: map title - indicator - event
		filename = params[:hidden_form_map_title].clone()
		filename << "-"
		filename << params[:hidden_form_indicator_name_abbrv]
		filename << "-"
		filename << params[:hidden_form_event_name]
		filename << "-#{l Time.now, :format => :file}"

		headers['Content-Type'] = "image/svg+xml; charset=utf-8"
    headers['Content-Disposition'] = "attachment; filename=#{clean_filename(filename)}.svg"
  end

  # GET /download
  # GET /download.json
  def download
    send_data = false
		if !params[:event_id].nil? && !params[:data_set_id].nil? && !params[:shape_type_id].nil? && !params[:shape_id].nil?
      #get the data
      dt = Datum.get_table_data(params[:event_id], params[:data_set_id], params[:shape_type_id], params[:shape_id])
			@data = dt[:data]

			if !@data.nil?
				# create file name using event name and map title that were passed in
		    filename = params[:map_title]
				filename << "-"
				filename << params[:event_name]
				filename << "-#{l Time.now, :format => :file}"

		    # send the file
				respond_to do |format|
				  format.csv {
logger.debug ">>>>>>>>>>>>>>>> format = csv"
						spreadsheet = DataArchive.create_csv_formatted_string(@data)

						send_data spreadsheet,
				    :type => 'text/csv; header=present',
				    :disposition => "attachment; filename=#{clean_filename(filename)}.csv"
					  send_data = true
					}

				  format.xls{
logger.debug ">>>>>>>>>>>>>>>> format = xls"
						spreadsheet = DataArchive.create_excel_formatted_string(@data)
						send_data spreadsheet,
				    :disposition => "attachment; filename=#{clean_filename(filename)}.xls"
					  send_data = true
					}
				end
			end
		end

		# if get here, then an error occurred
		if request.env["HTTP_REFERER"] && !send_data
			redirect_to :back, :notice => t("app.msgs.no_data_download")
		elsif !send_data
			redirect_to root_path, :notice => t("app.msgs.no_data_download")
		end

  end

  # GET /admin
  # GET /admin.json
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
	# get the default event to show when the site loads
	def set_default_event_params
		events = @event_types.map{|x| x.events.select{|y| y.is_default_view?}}.flatten
		if events && !events.empty?
			params[:event_type_id] = events.first.event_type_id.to_s
			params[:event_id] = events.first.id.to_s
			# if have live data and not official -> set to live
			# else -> set to official
			if !events.first.has_official_data? && events.first.has_live_data?
				params[:data_type] = Datum::DATA_TYPE[:live]
			else
				params[:data_type] = Datum::DATA_TYPE[:official]
			end
		end
	end

	# get the the current event
	def get_current_event(event_type_id, data_type, event_id=nil)
	  if event_type_id && data_type
	    event_type = @event_types.select{|x| x.id.to_s == event_type_id.to_s}
	    if event_type && !event_type.empty? && !event_type.first.events.empty?
	      if event_id
          # find the event that matches the passed in id
	        event = event_type.first.events.select{|x| x.id.to_s == event_id.to_s}
	        if event && !event.empty?
	          # check if have correct data type
	          return event.first if (event.first.has_official_data && data_type == Datum::DATA_TYPE[:official]) ||
	                                (event.first.has_live_data && data_type == Datum::DATA_TYPE[:live])
          end
        else
          # no id provided, so get first one with correct data type
          event_type.first.events.each do |event|
            if event.shape_id && (event.has_official_data && data_type == Datum::DATA_TYPE[:official]) ||
	                                (event.has_live_data && data_type == Datum::DATA_TYPE[:live])
            	# - save event_id
              params[:event_id] = event.id
              return event
            end
          end
        end
      end
    end
		# if get to here then no matching event was found
logger.debug " - no matching event found!"
		return nil
	end

	# get the shape type
	def get_shape_type(shape_type_id)
		if @shape_types.nil? || @shape_types.empty? || shape_type_id.nil?
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

	# get current indicator
	# returns:
	# {error, indicator_id, indicator_type_id, view_type}
	def get_current_indicator(indicator_types)
		hash = Hash.new()
		hash[:error] = false
		hash[:indicator_id] = nil
		hash[:indicator_type_id] = nil
		hash[:view_type] = nil

		if indicator_types && !indicator_types.empty?
			if indicator_types[0].has_summary
				hash[:view_type] = @summary_view_type_name
				hash[:indicator_type_id] = indicator_types[0].id
			elsif indicator_types[0].core_indicators.nil? || indicator_types[0].core_indicators.empty? ||
						indicator_types[0].core_indicators[0].indicators.nil? ||
						indicator_types[0].core_indicators[0].indicators.empty?
				# could not find an indicator
				logger.debug "+++++++++ cound not find an indicator to set as the value for params[:indicator_id]"
				hash[:error] = true
			else
				hash[:indicator_id] = indicator_types[0].core_indicators[0].indicators[0].id
				hash[:indicator_type_id] = indicator_types[0].id
			end
		end
		return hash
	end

  def set_gon_variables
    # shape json paths
		# - only children shape path needs the indicator id since that is the only layer that is clickable
		if !params[:shape_id].nil?
			gon.shape_path = json_shape_path(:id => params[:shape_id], :shape_type_id => @parent_shape_type)
			if params[:view_type] == @summary_view_type_name && @is_custom_view
  			gon.children_shapes_path = json_summary_custom_children_shapes_path(:parent_id => params[:shape_id],
  			  :event_id => params[:event_id], :indicator_type_id => params[:indicator_type_id],
  			  :shape_type_id => @child_shape_type_id, :custom_view => @is_custom_view.to_s,
					:data_type => params[:data_type], :data_set_id => params[:data_set_id])
			elsif params[:view_type] == @summary_view_type_name
  			gon.children_shapes_path = json_summary_children_shapes_path(:parent_id => params[:shape_id],
  			  :event_id => params[:event_id], :indicator_type_id => params[:indicator_type_id],
  			  :shape_type_id => @child_shape_type_id, :custom_view => @is_custom_view.to_s,
  			  :parent_shape_clickable => params[:parent_shape_clickable].to_s,
					:data_type => params[:data_type], :data_set_id => params[:data_set_id])
      elsif @is_custom_view
				gon.children_shapes_path = json_custom_children_shapes_path(:parent_id => params[:shape_id],
				  :indicator_id => params[:indicator_id], :shape_type_id => @child_shape_type_id,
				  :event_id => params[:event_id], :custom_view => @is_custom_view.to_s,
					:data_type => params[:data_type], :data_set_id => params[:data_set_id])
  		else
  			gon.children_shapes_path = json_children_shapes_path(:parent_id => params[:shape_id],
  			  :indicator_id => params[:indicator_id], :shape_type_id => @child_shape_type_id,
  			  :event_id => params[:event_id], :custom_view => @is_custom_view.to_s,
  			  :parent_shape_clickable => params[:parent_shape_clickable].to_s,
					:data_type => params[:data_type], :data_set_id => params[:data_set_id])
      end
		end

		# view type
		gon.view_type = params[:view_type]
		gon.summary_view_type_name = @summary_view_type_name

		# indicator name
		if !@indicator.nil?
			gon.indicator_name = @indicator.name
			gon.indicator_name_abbrv = @indicator.name_abbrv_w_parent
			gon.indicator_description = @indicator.description_w_parent
			gon.indicator_number_format = @indicator.number_format.nil? ? "" : @indicator.number_format
			gon.indicator_scale_colors = IndicatorScale.get_colors(@indicator.id)
		end

		# if summary view type, set indicator_description for legend title
		if params[:view_type] == @summary_view_type_name
			gon.indicator_description = I18n.t("app.msgs.map_summary_legend_title", :shape_type => @child_shape_type_name_singular_possessive)
		end

		# indicator scales
		if !params[:indicator_id].nil? && params[:view_type] != @summary_view_type_name
			build_indicator_scale_array
		end

    # save the map title for export
		if !params[:event_id].nil?
		  gon.event_id = params[:event_id]
		  gon.event_name = @event_name
		  gon.map_title = @map_title

			# data type
			gon.data_type = params[:data_type]
			gon.data_type_live = Datum::DATA_TYPE[:live]

			# data set id
			gon.data_set_id = params[:data_set_id]
			gon.data_set_id_most_recent = @most_recent_dataset.id if @most_recent_dataset
	  end

		# data table
    iid = (params[:indicator_id].nil? ? 'null' : params[:indicator_id])
    vt = (params[:view_type].nil? ? 'null' : params[:view_type])
		gon.data_table_path = data_table_path(:event_type_id => params[:event_type_id],
			:event_id => params[:event_id], :shape_id => params[:shape_id],
			:shape_type_id => params[:shape_type_id], :indicator_id => iid,
			:custom_view => params[:custom_view], :child_shape_type_id => @child_shape_type_id,
			:view_type => vt, :summary_view_type_name => @summary_view_type_name,
			:data_type => params[:data_type], :data_set_id => params[:data_set_id]
		)

		gon.dt_highlight_shape = (params[:highlight_shape].nil? ? false : params[:highlight_shape])

		# indicate indicator menu/scale block should be loaded
		gon.indicator_menu_scale = true

		# load openlayers js
		gon.openlayers = true
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
