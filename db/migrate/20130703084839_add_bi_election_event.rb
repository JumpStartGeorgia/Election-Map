# encoding: UTF-8
class AddBiElectionEvent < ActiveRecord::Migration
  def up
    # copy maj 2012 event to get shape
    event_clone = 32
    # copy maj 2012 event for components
    component_clone = 32

    Event.transaction do
      # feb 2013
      event = Event.clone_from_event(event_clone, '2013-04-27')
      if event.present?
        # update names
        event.event_translations.each do |trans|
          if trans.locale == 'ka'
            trans.name = '2013 წლის შუალედური საპარლამენტო არჩევნები - მაჟორიტარული'
            trans.name_abbrv = '2013 შუალედური მაჟორიტარული'
          else
            trans.name = '2013 Parliamentary Bi-election - Majoritarian'
            trans.name_abbrv = '2013 Bi-election Majoritarian'
          end
        end
        event.save

        # clone all of its components for the desired indicators
        # - get the indicators that existed before
        names = ['Total Turnout (#)', 'Total Turnout (%)', 'Free Georgia', 'National Democratic Party of Georgia', 'United National Movement', 'Movement for Fair Georgia', 'Freedom Party', 'Merab Kostava Society', 'Labour Council of Georgia', 'Labour', 'Georgian Dream']
        inds = CoreIndicator.includes(:core_indicator_translations).where(:core_indicator_translations => {:locale => 'en', :name => names})
        # -clone this indicators    
        event.clone_event_components(component_clone, inds.map{|x| x.id}) if inds.present?

        # now create the components for the new indicators
        # - get the new indicators
        names = ['Ioseb Manjavidze', 'Zviad Chitishvili', 'Roman Robakidze', 'Roman Robakidze']
        inds = CoreIndicator.includes(:core_indicator_translations).where(:core_indicator_translations => {:locale => 'en', :name => names})
        # - create components
        

      end
    end
  end

  def down
    events = Event.where(:event_date => '2013-04-27')
    if events.present?
      ids = events.map{|x| x.id}
      Event.transaction do
        EventIndicatorRelationship.where(:event_id => ids).delete_all

        views = EventCustomView.select("id").where(:event_id => ids)
        EventCustomViewTranslation.where(:event_custom_view_id => views.map{|x| x.id}).delete_all
        EventCustomView.where(:event_id => ids).delete_all

        indicators = Indicator.select("id").where(:event_id => ids)
        scales = IndicatorScale.select("id").where(:indicator_id => indicators.map{|x| x.id})
        IndicatorScaleTranslation.where(:indicator_scale_id => scales.map{|x| x.id}).delete_all
        IndicatorScale.where(:indicator_id => indicators.map{|x| x.id}).delete_all
        Indicator.where(:event_id => ids).delete_all

        EventTranslation.where(:event_id => ids).delete_all
        Event.where(:id => ids).delete_all
      end
    end
  end
end
