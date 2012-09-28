class AddIndRelFlagValue < ActiveRecord::Migration
  def up
		# apply openlayers rule value flag to all relationships
		# - mark the relationships as true where the parent and descendant are the same

		# first indicator types
		EventIndicatorRelationship.where("indicator_type_id is not null and indicator_type_id = related_indicator_type_id").each do |relationship|
			relationship.has_openlayers_rule_value = true
			relationship.save
		end

		# next core indicators
		EventIndicatorRelationship.where("core_indicator_id is not null and core_indicator_id = related_core_indicator_id").each do |relationship|
			relationship.has_openlayers_rule_value = true
			relationship.save
		end


		# now create relationship of new vpm indicator to itself and mark as not visible
    trans = CoreIndicatorTranslation.where(:name => 'Number of Precincts with votes per minute > 3')
		indicators = Indicator.where(:core_indicator_id => trans.first.core_indicator_id)
		indicators.map{|x| x.event_id}.uniq.each do |event_id|
		  EventIndicatorRelationship.create(:event_id => event_id,
		    :core_indicator_id => trans.first.core_indicator_id,
		    :related_core_indicator_id => trans.first.core_indicator_id,
				:visible => false,
		    :sort_order => 0)
		end
  end

  def down
    # delete all ancestry values
    connection = ActiveRecord::Base.connection()
    connection.execute("update event_indicator_relationships set has_openlayers_rule_value = false, visible = true")
  end
end
