class EventType < ActiveRecord::Base
  translates :name

  has_many :events
  has_many :event_type_translations, :dependent => :destroy
  accepts_nested_attributes_for :event_type_translations
  attr_accessible :id, :sort_order, :event_type_translations_attributes
  attr_accessor :locale

	default_scope lambda {with_translations(I18n.locale).order('sort_order')}
end
