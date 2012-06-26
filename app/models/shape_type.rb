class ShapeType < ActiveRecord::Base
  translates :name_singular, :name_plural
  has_ancestry

  has_many :indicators
  has_many :shapes
  has_many :shape_type_translations, :dependent => :destroy
  accepts_nested_attributes_for :shape_type_translations
  attr_accessible :id, :ancestry, :shape_type_translations_attributes
  attr_accessor :locale

  scope :l10n , joins(:shape_type_translations).where('locale = ?',I18n.locale)
  scope :by_name , order('name').l10n



	# get all of the shape types assigned to an event, via the event's shape_id
	def self.by_event(event_id)
		if !event_id.nil?
			event = Event.find(event_id)

			if !event.nil? && !event.shape_id.nil? && !event.shape.nil?
				parent_shape_type =  event.shape.shape_type
			end
		end
	end
end
