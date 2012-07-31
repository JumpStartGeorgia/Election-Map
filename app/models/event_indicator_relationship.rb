class EventIndicatorRelationship < ActiveRecord::Base
	belongs_to :event
	belongs_to :indicator_type
	belongs_to :core_indicator
	belongs_to :related_core_indicator, :class_name => "CoreIndicator", :foreign_key => "related_core_indicator_id"
	belongs_to :related_indicator_type, :class_name => "IndicatorType", :foreign_key => "related_indicator_type_id"

	attr_accessible :event_id, :indicator_type_id, :core_indicator_id, :related_core_indicator_id, :sort_order, :related_indicator_type_id

	validates :event_id, :sort_order, :presence => true
	default_scope order("sort_order asc")
end
