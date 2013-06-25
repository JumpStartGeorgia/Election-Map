# encoding: UTF-8
class Add2013VotersLists < ActiveRecord::Migration
  def up
    # copy august 2012 event to get shape
    event_clone = 22
    # copy may 2011 for components
    component_clone = 21

    Event.transaction do
      # feb 2013
      event = Event.clone_from_event(event_clone, '2013-02-01')
      if event.present?
        # update names
        event.event_translations.each do |trans|
          if trans.locale == 'ka'
            trans.name = '2012 წლის თებერვლის ამომრჩეველთა სია'
            trans.name_abbrv = '2012 თებერვლის'
          else
            trans.name = '2013 February Voters List'
            trans.name_abbrv = '2013 February'
          end
        end
        event.save

        # clone all of its components
        event.clone_event_components(component_clone)
      end


      # may 2013
      event = Event.clone_from_event(event_clone, '2013-05-01')
      if event.present?
        # update names
        event.event_translations.each do |trans|
          if trans.locale == 'ka'
            trans.name = '2012 წლის მაისის ამომრჩეველთა სია'
            trans.name_abbrv = '2012 მაისის'
          else
            trans.name = '2013 May Voters List'
            trans.name_abbrv = '2013 May'
          end
        end
        event.save

        # clone all of its components
        event.clone_event_components(component_clone)
      end

    end
  end

  def down
    events = Event.where(:event_date => ['2013-05-01', '2013-02-01'])
    if events.present?
      ids = events.map{|x| x.id}
      
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
