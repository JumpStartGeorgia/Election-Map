class ShapeType < ActiveRecord::Base
  translates :name_singular, :name_plural
  has_ancestry

  has_many :indicators
  has_many :shapes
  has_many :shape_type_translations, :dependent => :destroy
	has_many :event_custom_views, :dependent => :destroy
  accepts_nested_attributes_for :shape_type_translations
  attr_accessible :id, :ancestry, :shape_type_translations_attributes
  attr_accessor :locale

  scope :l10n , joins(:shape_type_translations).where('locale = ?',I18n.locale)
  scope :by_name , order('name').l10n


=begin
	# get all of the shape types assigned to an event, via the event's shape_id
	def self.by_event(event_id)
		shape_type_ids = []
		if !event_id.nil?
			event = Event.find(event_id)

			if !event.nil? && !event.shape_id.nil? && !event.shape.nil?
#				parent_shape_type = event.shape.shape_type
				shape_type_ids << event.shape.shape_type_id

				shape_type_ids << get_unique_shape_types(event.shape.children)
				shape_type_ids.flatten!
			end
		end

		return shape_type_ids
	end

protected

	def self.get_unique_shape_types(shapes)
		shape_type_ids = []
		x = shapes.select("distinct shape_type_id, ancestry")
		x.each do |s|
			shape_type_ids << s.shape_type_id
			# if there are children, continue the search
			if s.has_children?
				shape_type_ids << get_unique_shape_types(s.children)
			end
		end
		return shape_type_ids
	end
=end
end
