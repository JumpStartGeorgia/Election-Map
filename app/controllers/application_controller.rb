class ApplicationController < ActionController::Base
  protect_from_forgery
	require 'ostruct'

  before_filter :set_locale
  before_filter :set_election_types
  before_filter :set_shape_types
  before_filter :set_default_values
  
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
    @locales = Locale.order("language asc")
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
  end
  
  def set_election_types
    @event_types = EventType.all
  end
  
  def set_default_values
		@svg_directory_path = File.dirname(__FILE__)+"/../../public/assets/svg/"
  end
  
  def set_shape_types
    @shape_types = ShapeType.all
  end
  
  def default_url_options(options={})
    { :locale => I18n.locale }
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
