class ApplicationController < ActionController::Base
   protect_from_forgery
	require 'ostruct'
	require 'utf8_converter'

   layout "application-bootstrap"

   before_filter :set_locale
   before_filter :is_browser_supported?
   before_filter :set_event_types
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
		Browser.new("Safari", "5.1"),
		Browser.new("Firefox", "13.0"),
		Browser.new("Internet Explorer", "9.0"),
		Browser.new("Opera", "11.0")
	]

	def is_browser_supported?
		user_agent = UserAgent.parse(request.user_agent)
logger.debug "////////////////////////// BROWSER = #{user_agent}"
		if SUPPORTED_BROWSERS.any? { |browser| user_agent < browser }
			# browser not supported
logger.debug "////////////////////////// BROWSER NOT SUPPORTED"
			render "layouts/unsupported_browser", :layout => false
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

  def set_event_types
logger.debug "---********----- event type cache"
    @event_types = Rails.cache.fetch("event_types_#{I18n.locale}") {
			x = EventType.all
			# do this to force a call to the db to get the data
			# so the data will actually be cached
			x.collect{|x| x}
		}
#    @event_types = EventType.all
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
#    gon.tile_url = "http://tile.mapspot.ge/#{lang}/${z}/${x}/${y}.png"
    gon.tile_url = "http://91.212.213.147/#{lang}/${z}/${x}/${y}.png"
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


	def render_not_found(exception)
		ExceptionNotifier::Notifier
		  .exception_notification(request.env, exception)
		  .deliver
		render :file => "#{Rails.root}/public/404.html", :status => 404
	end

	def render_error(exception)
		ExceptionNotifier::Notifier
		  .exception_notification(request.env, exception)
		  .deliver
		render :file => "#{Rails.root}/public/500.html", :status => 500
	end

end
