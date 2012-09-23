class CreatePartyListRelationships < ActiveRecord::Migration
  def up
    event_id = 31
    
    # create custom view
    # copy from 2008 record
    custom = EventCustomView.where(:event_id => 3)    
    new_custom = EventCustomView.create(:event_id => event_id, 
      :shape_type_id => custom.first.shape_type_id, 
      :descendant_shape_type_id => custom.first.descendant_shape_type_id, 
      :is_default_view => custom.first.is_default_view)
    en = custom.first.event_custom_view_translations.select{|x| x.locale == "en"}
    new_custom.event_custom_view_translations.create(:locale => 'en', :note => en.first.note)
    ka = custom.first.event_custom_view_translations.select{|x| x.locale == "ka"}
    new_custom.event_custom_view_translations.create(:locale => 'ka', :note => ka.first.note)
    
    # create relationships
    # copy from 2008 record
    relationships = EventIndicatorRelationship.where(:event_id => 3)
    relationships.each do |r|
      EventIndicatorRelationship.create(:event_id => event_id, 
        :indicator_type_id => r.indicator_type_id, 
        :core_indicator_id => r.core_indicator_id, 
        :related_core_indicator_id => r.related_core_indicator_id, 
        :sort_order => r.sort_order, 
        :related_indicator_type_id => r.related_indicator_type_id)
    end

    # create new relationships for the precincts reported indicators
    prec_num = 68
    prec_perc = 69
    total_turnout = 15
    
      EventIndicatorRelationship.create(:event_id => event_id, 
        :core_indicator_id => prec_num, 
        :related_core_indicator_id => prec_num, 
        :sort_order => 1)
      EventIndicatorRelationship.create(:event_id => event_id, 
        :core_indicator_id => prec_num, 
        :related_core_indicator_id => prec_perc, 
        :sort_order => 2)
      EventIndicatorRelationship.create(:event_id => event_id, 
        :core_indicator_id => prec_num, 
        :related_core_indicator_id => total_turnout, 
        :sort_order => 3)

      EventIndicatorRelationship.create(:event_id => event_id, 
        :core_indicator_id => prec_perc, 
        :related_core_indicator_id => prec_num, 
        :sort_order => 1)
      EventIndicatorRelationship.create(:event_id => event_id, 
        :core_indicator_id => prec_perc, 
        :related_core_indicator_id => prec_perc, 
        :sort_order => 2)
      EventIndicatorRelationship.create(:event_id => event_id, 
        :core_indicator_id => prec_perc, 
        :related_core_indicator_id => total_turnout, 
        :sort_order => 3)
    
  end

  def down
    event_id = 31
    EventIndicatorRelationship.where(:event_id => event_id).destroy_all
    EventCustomView.where(:event_id => event_id).destroy_all
  end
end
