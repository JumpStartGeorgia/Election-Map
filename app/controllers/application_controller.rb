class ApplicationController < ActionController::Base
  protect_from_forgery
	require 'ostruct'

  before_filter :set_locale
  before_filter :set_election_types
  before_filter :set_shape_types
  before_filter :set_default_values
  
  def set_locale
    I18n.locale = params[:locale] if params[:locale]
    @locales = Locale.all
  end
  
  def set_election_types
    @event_types = EventType.all
  end
  
  def set_default_values
		@default_values = Array.new(2) {OpenStruct.new}
		@default_values[0].event_type_id = "1"
		@default_values[0].event_id = "2"
		@default_values[0].shape_type_id = "1"
		@default_values[0].shape_id = "10753"
		@default_values[1].event_type_id = "2"
		@default_values[1].event_id = "1"
		@default_values[1].shape_type_id = "1"
		@default_values[1].shape_id = "10753"
  end
  
  def set_shape_types
    @shape_types = ShapeType.all
  end
  
  def default_url_options(options={})
    { :locale => I18n.locale }
  end

end
