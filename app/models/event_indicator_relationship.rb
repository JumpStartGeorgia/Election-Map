class EventIndicatorRelationship < ActiveRecord::Base
	belongs_to :event
	belongs_to :indicator_type
	belongs_to :core_indicator
	belongs_to :related_core_indicator, :class_name => "CoreIndicator", :foreign_key => "related_core_indicator_id"
	belongs_to :related_indicator_type, :class_name => "IndicatorType", :foreign_key => "related_indicator_type_id"

	attr_accessible :event_id, :indicator_type_id, :core_indicator_id, :visible,
		:related_core_indicator_id, :sort_order, :related_indicator_type_id, :has_openlayers_rule_value

	validates :event_id, :sort_order, :presence => true
	default_scope order("sort_order asc")

  # get all indicator types that are not currently part of an indicator relationship
  def self.indicator_type_ids_in_event(event_id)
		if event_id
			select("distinct indicator_type_id")
			.where("event_id = ? and indicator_type_id is not null", event_id)
		end
  end

  # get all core indicators that are not currently part of an indicator relationship
  def self.core_indicator_ids_in_event(event_id)
		if event_id
			select("distinct core_indicator_id")
			.where("event_id = ? and core_indicator_id is not null", event_id)
		end
  end

end
