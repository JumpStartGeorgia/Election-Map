class EventType < ActiveRecord::Base
  translates :name

  has_many :events
  has_many :event_type_translations, :dependent => :destroy
  accepts_nested_attributes_for :event_type_translations
  attr_accessible :event_type_translations_attributes
  attr_accessor :locale

  scope :l10n , joins(:event_type_translations).where('locale = ?',I18n.locale)
  scope :by_name , order('name').l10n
end
