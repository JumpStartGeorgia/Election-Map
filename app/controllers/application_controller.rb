class ApplicationController < ActionController::Base
   protect_from_forgery
	require 'ostruct'
	require 'utf8_converter'

   layout "application-bootstrap"

   before_filter :set_locale
   before_filter :is_browser_supported?
	 before_filter :set_data_type
   before_filter :set_event_types
   before_filter :set_event_menu
   before_filter :set_live_event_menu
   before_filter :set_shape_types
   before_filter :set_default_values
   before_filter :set_gon_data
	before_filter :set_summary_view_type_name

	unless Rails.application.config.consider_all_requests_local
		rescue_from Exception,
		            :with => :render_error
		rescue_from ActiveRecord::RecordNotFound,
		            :with => :render_not_found
		rescue_from ActionController::RoutingError,
		            :with => :render_not_found
		rescue_from ActionController::UnknownController,
		            :with => :render_not_found
		rescue_from ActionController::UnknownAction,
		            :with => :render_not_found
	end

protected

	Browser = Struct.new(:browser, :version)
	SUPPORTED_BROWSERS = [
		Browser.new("Chrome", "15.0"),
		Browser.new("Safari", "4.0.2"),
		Browser.new("Firefox", "10.0.2"),
		Browser.new("Internet Explorer", "9.0"),
		Browser.new("Opera", "11.0")
	]

	def is_browser_supported?
		user_agent = UserAgent.parse(request.user_agent)
logger.debug "////////////////////////// BROWSER = #{user_agent}"
		if SUPPORTED_BROWSERS.any? { |browser| user_agent < browser }
			# browser not supported
logger.debug "////////////////////////// BROWSER NOT SUPPORTED"
#			render "layouts/unsupported_browser", :layout => false
			@error_type = "unsupported_browser"
			render "layouts/error", :layout => false
		end
	end


  def set_locale
    if params[:locale] and I18n.available_locales.include?(params[:locale].to_sym)
      I18n.locale = params[:locale]
    else
			# param not set
      I18n.locale = I18n.default_locale
    end
  end

  def default_url_options(options={})
    { :locale => I18n.locale }
  end

	def set_data_type
		# get the data type
		params[:data_type] = Datum::DATA_TYPE[:official] if params[:data_type].nil? || Datum::DATA_TYPE.values.index(params[:data_type]) == nil

		if params[:data_type] == Datum::DATA_TYPE[:live]
			@show_precinct_percentages = false
		end
	end

  def set_event_types
logger.debug "---********----- event type cache"
    @event_types = Rails.cache.fetch("event_types_#{I18n.locale}") {
			event_types = EventType.with_public_events
      # do this to force a call to the db to get the data
			# so the data will actually be cached
      event_types.collect{|x| x}
		}
  end

	# format:
	# [ { id, name, events => [ { id, url, description } ] } ]
  def set_event_menu
		json = Rails.cache.fetch("event_menu_json_#{I18n.locale}") {
			json = []
			if @event_types && !@event_types.empty?
				@event_types.each do |event_type|
					type = Hash.new
					json << type
					type["id"] = event_type.id
					type["name"] = event_type.name
					type["events"] = []

					event_type.events.get_public_events_by_type(event_type.id).each do |event|
						if !event.shape_id.nil?
							e = Hash.new
							type["events"] << e
							e["id"] = event.id
              e["name"] = event.name
							e["description"] = event.description
              e["url_official"] = nil
              e["url_live"] = nil
              if event.has_official_data
  							e["url_official"] = view_context.url_for(indicator_map_path(
  								:event_id => event.id, :event_type_id => event.event_type_id,
  								:shape_id => event.shape_id, :shape_type_id => event.shape.nil? ? nil : event.shape.shape_type_id,
  						    :data_type => Datum::DATA_TYPE[:official],
  								:only_path => false))
              end
              if event.has_live_data
  							e["url_live"] = view_context.url_for(indicator_map_path(
  								:event_id => event.id, :event_type_id => event.event_type_id,
  								:shape_id => event.shape_id, :shape_type_id => event.shape.nil? ? nil : event.shape.shape_type_id,
  						    :data_type => Datum::DATA_TYPE[:live],
  								:only_path => false))
              end
						end
					end
				end
			end
			json
		}

		# if returned from cache, the obj will be string and need to convert back to array/hashes
		if json.class == String
			@event_menu = JSON.parse(json)
		else
			@event_menu = json
		end
  end

	# format:
	# [ { id, url, description, :date_available_at } ]
  def set_live_event_menu
		json = Rails.cache.fetch("live_event_menu_json_#{I18n.locale}") {
			json = []

			Event.active_live_events_menu.each do |event|
				if !event.shape_id.nil?
					e = Hash.new
					json << e
					e["id"] = event.id
					e["url"] = view_context.link_to(event.name, indicator_map_path(
						:event_id => event.id, :event_type_id => event.event_type_id,
						:shape_id => event.shape_id, :shape_type_id => event.shape.nil? ? nil : event.shape.shape_type_id,
						:data_type => Datum::DATA_TYPE[:live],
						:only_path => false))
					e["name"] = event.name
					e["description"] = event.description
          e["data_available_at"] = nil
					e["data_available_at"] = event.menu_live_events.first.data_available_at if event.menu_live_events && !event.menu_live_events.empty?
				end
			end
			json
		}

		# if returned from cache, the obj will be string and need to convert back to array/hashes
		if json.class == String
			@live_event_menu = JSON.parse(json)
		else
			@live_event_menu = json
		end
  end

  def set_shape_types
logger.debug "---********----- shape type cache"
    @shape_types = Rails.cache.fetch("shape_types") {
			x = ShapeType.with_translations(I18n.locale)
			# do this to force a call to the db to get the data
			# so the data will actually be cached
			x.collect{|x| x}
		}
#    @shape_types = ShapeType.all
  end

  def set_default_values
		@svg_directory_path = File.dirname(__FILE__)+"/../../public/assets/svg/"
  end

	def set_gon_data
		# set no data label text and color for legend
		gon.no_data_text = I18n.t('app.msgs.no_data')
		gon.no_data_color = "#CCCCCC"
    # tile url
    lang = I18n.locale.to_s == 'ka' ? 'ka' : 'en'
#    gon.tile_url = "http://tile.mapspot.ge/new_#{lang}/${z}/${x}/${y}.png"
#    gon.tile_url = "http://91.212.213.147/new_#{lang}/${z}/${x}/${y}.png"
		gon.tile_url = "http://tile.openstreetmap.org/${z}/${x}/${y}.png"
    gon.openlayers_img_path = "/assets/img/"
	end

	# name for summary view type
	def set_summary_view_type_name
	  @summary_view_type_name = "summary"
  end

	# after user logs in, go to admin page
	def after_sign_in_path_for(resource)
		admin_path
	end

	# remove bad characters from file name
	def clean_filename(filename)
		Utf8Converter.convert_ka_to_en(filename.gsub(' ', '_').gsub(/[\\ \/ \: \* \? \" \< \> \| \, \. ]/,''))
	end

	# create an array of items, ordered by ancestry value
	def ancestry_options(items, &block)
    return ancestry_options(items){ |i| "#{'-' * i.depth} #{i.name}" } unless block_given?

    result = []
    items.map do |item|
      result << {"name" => yield(item), "id" => item.id}
    end
    result
  end

	# send email status update
  def send_status_update(message, time = nil)
    @message = Message.new
		@message.name = "Application Status Update Notification"
		@message.email = current_user.email
		@message.time = time
		@message.message = message
    if @message.valid?
      # send message
			ContactMailer.status_update(@message).deliver
			@email_sent = true
    end
  end

  # compute duration for start time to end time
  # return format is hh:dd:mm:ss
  # taken from https://www.tropo.com/scripting/2.0/t_ruby-countdown.htm
  def countdown_duration(start_time, end_time)
    duration = nil
    if start_time && end_time
      # Calculate the difference between now and then
      difference = end_time - start_time

      #calculating the days, hours, minutes and seconds
      #out of the initial large seconds value generated by 'difference',
      #then dropping the values after the decimal
      days = (difference / (60*60*24)).to_i
      days_remainder = (difference % (60*60*24)).to_i
      hours = (days_remainder / (60*60)).to_i
      hours_remainder = (days_remainder % (60 * 60)).to_i
      minutes = (hours_remainder / 60).to_i
      seconds = (hours_remainder % 60).to_i

      # apply leading zero if needed
      duration = ""
      if days < 10
        duration << "0"
      end
      duration << days.to_s
      duration << ":"
      if hours < 10
        duration << "0"
      end
      duration << hours.to_s
      duration << ":"
      if minutes < 10
        duration << "0"
      end
      duration << minutes.to_s
      duration << ":"
      if seconds < 10
        duration << "0"
      end
      duration << seconds.to_s

    end
    return duration
  end

	def render_not_found(exception)
		ExceptionNotifier::Notifier
		  .exception_notification(request.env, exception)
		  .deliver
#		render :file => "#{Rails.root}/public/404.html", :status => 404
		@error_type = "404"
		render "layouts/error", :layout => false
	end

	def render_error(exception)
		ExceptionNotifier::Notifier
		  .exception_notification(request.env, exception)
		  .deliver
		@error_type = "500"
		render "layouts/error", :layout => false
#		render :file => "#{Rails.root}/public/500.html", :status => 500
	end

end
