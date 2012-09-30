class Event < ActiveRecord::Base
  translates :name, :name_abbrv, :description

  has_many :event_translations, :dependent => :destroy
  has_many :indicators
	has_many :menu_live_events, :dependent => :destroy
  belongs_to :shape
  belongs_to :event_type
  has_many :event_indicator_relationships, :dependent => :destroy
	has_many :event_custom_views, :dependent => :destroy
	has_many :data_sets, :dependent => :destroy
  accepts_nested_attributes_for :event_translations
  attr_accessible :shape_id, :event_type_id, :event_date,
		:event_translations_attributes, :has_official_data, :has_live_data

  validates :event_type_id, :event_date, :presence => true
  #do not require shape id for the geo data might not be loaded yet
#  validates :shape_id, :presence => true

	# get all events that have live menu records
	def self.live_events_menu(order = "asc")
		with_translations(I18n.locale)
		.joins(:menu_live_events)
		.order("menu_live_events.menu_start_date #{order}, event_date, event_translations.name")
	end

	# get all events that have live accounts and are currently active
	def self.active_live_events_menu(order = "asc")
		with_translations(I18n.locale)
		.includes(:menu_live_events)
		.where("curdate() between menu_live_events.menu_start_date and menu_live_events.menu_end_date")
		.order("menu_live_events.menu_start_date #{order}, event_date, event_translations.name")
#		.where("events.has_live_data = 1 and curdate() between menu_live_events.menu_start_date and menu_live_events.menu_end_date")
	end


  def self.get_public_events_by_type(event_type_id)
    if event_type_id
			Rails.cache.fetch("events_by_type_#{event_type_id}_#{I18n.locale}") {
				x = Event.with_translations(I18n.locale)
				.where("event_type_id = ? and shape_id is not null and (has_official_data = 1 || has_live_data = 1)", event_type_id)
				.order("event_date DESC, event_translations.name ASC")
				# do this to force a call to the db to get the data
				# so the data will actually be cached
				x.collect{|x| x}
			}
    end
  end

	# get all events that have datasets
	def self.data_sets(order = "asc")
		with_translations(I18n.locale)
		.joins(:data_sets)
		.order("data_sets.timestamp #{order}, event_translations.name")
	end

  def self.get_events_by_type(event_type_id)
    if event_type_id.nil?
      return nil
    else
			Rails.cache.fetch("events_by_type_#{event_type_id}_#{I18n.locale}") {
				x = Event.with_translations(I18n.locale)
				.where("event_type_id = ? and shape_id is not null and (has_official_data = 1 or has_live_data = 1)", event_type_id)
				.order("event_date DESC, event_translations.name ASC")
				# do this to force a call to the db to get the data
				# so the data will actually be cached
				x.collect{|x| x}
			}
    end
  end

  def self.get_all_events(locale = I18n.locale)
		with_translations(locale).includes(:event_type)
		.order("event_types.sort_order asc, event_date DESC, event_translations.name ASC")
  end

  def self.get_all_events_by_date(locale = I18n.locale)
		with_translations(locale)
		.order("event_date DESC, event_translations.name ASC")
  end

  def self.get_all_election_events_by_date(locale = I18n.locale)
		with_translations(locale)
		.where("event_type_id in (1,3,4,5)")
		.order("event_date DESC, event_translations.name ASC")
  end

	def self.get_events_with_summary_indicators
		select("distinct events.id, events.shape_id, core_indicators.indicator_type_id, events.has_official_data, events.has_live_data")
		.joins(:indicators => {:core_indicator => :indicator_type})
		.where(:indicator_types => {:has_summary => true})
		.order("events.id")
	end
end
