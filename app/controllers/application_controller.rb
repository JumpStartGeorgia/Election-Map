class ApplicationController < ActionController::Base
  protect_from_forgery
	require 'ostruct'

  before_filter :set_locale
  before_filter :set_event_types
  before_filter :set_shape_types
  before_filter :set_default_values
	before_filter :set_gon_data
  
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

  def set_locale
    @locales = Rails.cache.fetch("locales") {Locale.all}
#    @locales = Locale.order("language asc")
=begin
		# see if locale is valid
		valid = false
		if !params[:locale].nil?
			@locales.each do |l|
				if l.language.downcase == params[:locale].downcase
					valid = true
					break
				end
			end
			if valid
			  I18n.locale = params[:locale] if params[:locale]
			else
			  I18n.locale = I18n.default_locale
			  params[:locale] = I18n.default_locale
			end
		end
=end
    if params[:locale] and I18n.available_locales.include?(params[:locale].to_sym)
      I18n.locale = params[:locale]
    else
      I18n.locale = I18n.default_locale
    end
  end
  
  def default_url_options(options={})
    { :locale => I18n.locale }
  end

  def set_event_types
    @event_types = Rails.cache.fetch("event_types") {EventType.all}
#    @event_types = EventType.all
  end
  
  def set_shape_types
    @shape_types = Rails.cache.fetch("shape_types") {ShapeType.all}
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
#    lang = I18n.locale.to_s == 'ka' ? 'ka' : 'en'
#    gon.tile_url = "http://tile.mapspot.ge/#{lang}/${z}/${x}/${y}.png"
	end

	# after user logs in, go to admin page	
	def after_sign_in_path_for(resource)
		admin_path
	end

	# remove bad characters from file name
	def clean_filename(filename)
		filename.gsub!(' ', '_').gsub!(/[\\ \/ \: \* \? \" \< \> \| \, \. ]/,'')
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
