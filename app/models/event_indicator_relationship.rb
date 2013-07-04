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

  def clone_for_event(event_id)
    if event_id.present?
      EventIndicatorRelationship.create(:event_id => event_id, 
        :indicator_type_id => self.indicator_type_id, :core_indicator_id => self.core_indicator_id, 
    		:related_core_indicator_id => self.related_core_indicator_id, :related_indicator_type_id => self.related_indicator_type_id,
        :visible => self.visible, :sort_order => self.sort_order, :has_openlayers_rule_value => self.has_openlayers_rule_value)
    end
  end

  # copy all relationships from an indicator in an event to a different indicator in an event
  # - if a relationship's related_core_indicator_id = from_core_indicator_id, 
  #   then replace it with the to_core_indicator_id
  def self.clone_from_core_indicator(from_event_id, from_core_indicator_id, to_event_id, to_core_indicator_id)
    if from_event_id.present? && from_core_indicator_id.present? && to_event_id.present? && to_core_indicator_id.present?
      # get the previous relationship
      from = EventIndicatorRelationship.where(:event_id => from_event_id, :core_indicator_id => from_core_indicator_id)
      if from.present?
        from.each do |rel|
          related_core_ind_id = rel.related_core_indicator_id == from_core_indicator_id ? to_core_indicator_id : rel.related_core_indicator_id
          EventIndicatorRelationship.create(:event_id => to_event_id, 
            :core_indicator_id => to_core_indicator_id, 
        		:related_core_indicator_id => related_core_ind_id, :related_indicator_type_id => rel.related_indicator_type_id,
            :visible => rel.visible, :sort_order => rel.sort_order, :has_openlayers_rule_value => rel.has_openlayers_rule_value)
        end
      end
    end
  end
end
