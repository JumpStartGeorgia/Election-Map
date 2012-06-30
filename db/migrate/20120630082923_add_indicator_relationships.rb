class AddIndicatorRelationships < ActiveRecord::Migration
  def up
    EventIndicatorRelationship.destroy_all

    #IMPORTANT - must include id of self indicator in relation so it will
    # be included in the relationship

    event = Event.find(2)

    # party results indicator type with total turnout #
    cit1 = CoreIndicatorTranslation.where(:name_abbrv => "TT#", :locale => "en")
    EventIndicatorRelationship.create(:event_id => event.id, :indicator_type_id => 2, 
      :related_indicator_type_id => 2, :sort_order => 1)
    EventIndicatorRelationship.create(:event_id => event.id, :indicator_type_id => 2, 
      :related_core_indicator_id => cit1.first.core_indicator_id, :sort_order => 2)
    
    # TT# => TT%
    cit1 = CoreIndicatorTranslation.where(:name_abbrv => "TT#", :locale => "en")
    cit2 = CoreIndicatorTranslation.where(:name_abbrv => "TT%", :locale => "en")
    EventIndicatorRelationship.create(:event_id => event.id, :core_indicator_id => cit1.first.core_indicator_id, 
      :related_core_indicator_id => cit1.first.core_indicator_id, :sort_order => 1)
    EventIndicatorRelationship.create(:event_id => event.id, :core_indicator_id => cit1.first.core_indicator_id, 
      :related_core_indicator_id => cit2.first.core_indicator_id, :sort_order => 2)

    # TT% => TT#
    EventIndicatorRelationship.create(:event_id => event.id, :core_indicator_id => cit2.first.core_indicator_id, 
      :related_core_indicator_id => cit1.first.core_indicator_id, :sort_order => 1)
    EventIndicatorRelationship.create(:event_id => event.id, :core_indicator_id => cit2.first.core_indicator_id, 
      :related_core_indicator_id => cit2.first.core_indicator_id, :sort_order => 2)

  end

  def down
    EventIndicatorRelationship.destroy_all
  end
end
