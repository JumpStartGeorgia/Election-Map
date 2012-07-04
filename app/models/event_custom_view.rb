class EventCustomView < ActiveRecord::Base
	belongs_to :event
	belongs_to :shape_type
	belongs_to :descendant_shape_type, :class_name => "ShapeType", :foreign_key => "descendant_shape_type_id"

	attr_accessible :event_id, :shape_type_id, :descendant_shape_type_id, :is_default_view
end
