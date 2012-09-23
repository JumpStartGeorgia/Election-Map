class ShapeType < ActiveRecord::Base
  translates :name_singular, :name_plural, :name_singular_possessive
  has_ancestry

  has_many :indicators
  has_many :shapes
  has_many :shape_type_translations, :dependent => :destroy
	has_many :event_custom_views, :dependent => :destroy
  accepts_nested_attributes_for :shape_type_translations
  attr_accessible :id, :ancestry, :is_precinct, :shape_type_translations_attributes
  attr_accessor :locale

	scope :precincts, where(:is_precinct => true)

	# get all of the shape types assigned to an event, via the event's shape_id
	def self.by_event(event_id)
		shape_types = []
		shape_type_ids = nil
		if !event_id.nil?
			event = Event.find(event_id)

			if !event.nil? && !event.shape_id.nil? && !event.shape.nil?
			  # if the shape tied to the event is not the root, switch to the root
			  shape = event.shape.is_root? ? event.shape : event.shape.root

				# get all distinct shape_type_ids for this shape set
				shape_type_ids = shape.subtree.select("distinct shape_type_id")

				if !shape_type_ids.nil? && !shape_type_ids.empty?
					# get each shape_type object
					shape_type_ids.each do |shape|
						shape_types << shape.shape_type
					end
					return shape_types
				end
			end
		end

	end

end
