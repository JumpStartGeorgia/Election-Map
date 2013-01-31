class AddAdjScRelationships < ActiveRecord::Migration
  def up
    event_ids = [33,34]
    copy_from_id = 31
    
    puts 'get core ids being used for these events'
    core_ids = Indicator.select('distinct core_indicator_id').where(:event_id => event_ids).map{|x| x.core_indicator_id}

    puts 'create relationships'
    EventIndicatorRelationship.where(:event_id => copy_from_id).each do |relationship|
      # if this is an indicator type or an indicator from the list, add it
      if relationship.indicator_type_id || core_ids.index(relationship.core_indicator_id)
        puts "adding relationship: ind type id = #{relationship.indicator_type_id}; core id = #{relationship.core_indicator_id}"
        event_ids.each do |event_id|
          EventIndicatorRelationship.create(
            :event_id => event_id,
            :indicator_type_id => relationship.indicator_type_id, 
            :core_indicator_id => relationship.core_indicator_id, 
            :visible => relationship.visible,
        		:related_core_indicator_id => relationship.related_core_indicator_id, 
            :sort_order => relationship.sort_order, 
            :related_indicator_type_id => relationship.related_indicator_type_id, 
            :has_openlayers_rule_value => relationship.has_openlayers_rule_value
          )
        end
      end
    end    
  end

  def down
    event_ids = [33,34]

    EventIndicatorRelationship.where(:event_id => event_ids).delete_all    
  end
end
