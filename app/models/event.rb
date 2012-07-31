class Event < ActiveRecord::Base
  translates :name, :name_abbrv

  has_many :event_translations, :dependent => :destroy
  has_many :indicators
  belongs_to :shape
  belongs_to :event_type
  has_many :event_indicator_relationships, :dependent => :destroy
	has_many :event_custom_views, :dependent => :destroy
  accepts_nested_attributes_for :event_translations
  attr_accessible :shape_id, :event_type_id, :event_date, :event_translations_attributes
  attr_accessor :locale

  validates :event_type_id, :event_date, :presence => true
  #do not require shape id for the geo data might not be loaded yet
#  validates :shape_id, :presence => true

  scope :l10n , joins(:event_translations).where('locale = ?',I18n.locale)
  scope :by_name , order('name').l10n


  def self.get_events_by_type(event_type_id)
    if event_type_id.nil?
      return nil
    else
			Rails.cache.fetch("events_by_type_#{event_type_id}_#{I18n.locale}") {
				x = Event.with_translations(I18n.locale)
				.where(:event_type_id => event_type_id)
				.order("event_date DESC, event_translations.name ASC")
				# do this to force a call to the db to get the data
				# so the data will actually be cached
				x.collect{|x| x}
			}
=begin
      includes(:event_translations)
      .where(:event_type_id => event_type_id)
      .order("event_date DESC, event_translations.name ASC")
=end
    end
  end

  def self.get_all_events(locale = I18n.locale)
		with_translations(locale).includes(:event_type)
		.order("event_types.sort_order asc, event_date DESC, event_translations.name ASC")
  end
end
