# encoding: UTF-8
    total_ind_id = 15
    event_names = ['2012 Parliamentary - Party List', '2012 Parliamentary - Majoritarian']
    events = Event.includes(:event_translations).where(:event_translations => {:name => event_names, :locale => 'en'})

    if events.present? && events.length == event_names.length
      CoreIndicator.transaction do
        ##########################
        # add core inds
        # precincts with missing ballots (%)
        exists = CoreIndicatorTranslation.where(:locale => 'en', :name => 'Precincts with Missing Ballots (%)')
        if exists.present?
          prec_missing_perc = CoreIndicator.find_by_id(exists.first.core_indicator_id)
        else
          prec_missing_perc = CoreIndicator.create(:indicator_type_id => 1, :number_format => '%')
          prec_missing_perc.core_indicator_translations.create(:locale => 'en', :name => 'Precincts with Missing Ballots (%)',
            :name_abbrv => 'Missing Ballots (%)', :description => 'Precincts with Missing Ballots (%)')
          prec_missing_perc.core_indicator_translations.create(:locale => 'ka', :name => 'საარჩევნო უბნები, რომლებსაც აქვთ (%) დაკარგული ბიულეტენი',
            :name_abbrv => 'დაკარგული ბიულეტენები (%)', :description => 'საარჩევნო უბნები, რომლებსაც აქვთ (%) დაკარგული ბიულეტენი')
        end
        
        # precincts with missing ballots (#)
        exists = CoreIndicatorTranslation.where(:locale => 'en', :name => 'Precincts with Missing Ballots (#)')
        if exists.present?
          prec_missing_num = CoreIndicator.find_by_id(exists.first.core_indicator_id)
        else
          prec_missing_num = CoreIndicator.create(:indicator_type_id => 1)
          prec_missing_num.core_indicator_translations.create(:locale => 'en', :name => 'Precincts with Missing Ballots (#)',
            :name_abbrv => 'Missing Ballots (#)', :description => 'Precincts with Missing Ballots (#)')
          prec_missing_num.core_indicator_translations.create(:locale => 'ka', :name => 'საარჩევნო უბნები, რომლებსაც აქვთ (#) დაკარგული ბიულეტენი',
            :name_abbrv => 'დაკარგული ბიულეტენები (#)', :description => 'საარჩევნო უბნები, რომლებსაც აქვთ (#) დაკარგული ბიულეტენი')
        end
        
        # avg # of missing ballots
        exists = CoreIndicatorTranslation.where(:locale => 'en', :name => 'Average Number of Missing Ballots')
        if exists.present?
          avg = CoreIndicator.find_by_id(exists.first.core_indicator_id)
        else
          avg = CoreIndicator.create(:indicator_type_id => 1)
          avg.core_indicator_translations.create(:locale => 'en', :name => 'Average Number of Missing Ballots',
            :name_abbrv => 'Avg Num Missing Ballots', :description => 'Average Number of Missing Ballots')
          avg.core_indicator_translations.create(:locale => 'ka', :name => 'დაკარგული ბიულეტენების საშუალო რაოდენობა',
            :name_abbrv => 'დაკარგული ბიულეტენების საშ. რაოდენობა', :description => 'დაკარგული ბიულეტენების საშუალო რაოდენობა')
        end

        # missing ballots (#)
        exists = CoreIndicatorTranslation.where(:locale => 'en', :name => 'Number of Missing Ballots')
        if exists.present?
          missing = CoreIndicator.find_by_id(exists.first.core_indicator_id)
        else
          missing = CoreIndicator.create(:indicator_type_id => 1)
          missing.core_indicator_translations.create(:locale => 'en', :name => 'Number of Missing Ballots',
            :name_abbrv => 'Missing Ballots (#)', :description => 'Number of Missing Ballots')
          missing.core_indicator_translations.create(:locale => 'ka', :name => 'დაკარგული ბიულეტენების რაოდენობა',
            :name_abbrv => 'დაკარგული ბიულეტენები (#)', :description => 'დაკარგული ბიულეტენების რაოდენობა')
        end
        
        
        events.each do |event|
          # add if not exists
          if EventIndicatorRelationship.where(:event_id => event.id, :core_indicator_id => prec_missing_perc.id).blank? &&
              EventIndicatorRelationship.where(:event_id => event.id, :core_indicator_id => missing.id).blank?
            ##########################
            # create relationships
            # - non-precinct relationship
            EventIndicatorRelationship.create(:event_id => event.id, :core_indicator_id => prec_missing_perc.id, :related_core_indicator_id => prec_missing_num.id,
              :sort_order => 1, :visible => true, :has_openlayers_rule_value => false)
            EventIndicatorRelationship.create(:event_id => event.id, :core_indicator_id => prec_missing_perc.id, :related_core_indicator_id => prec_missing_perc.id,
              :sort_order => 2, :visible => true, :has_openlayers_rule_value => true)
            EventIndicatorRelationship.create(:event_id => event.id, :core_indicator_id => prec_missing_perc.id, :related_core_indicator_id => avg.id,
              :sort_order => 3, :visible => true, :has_openlayers_rule_value => false)
            EventIndicatorRelationship.create(:event_id => event.id, :core_indicator_id => prec_missing_perc.id, :related_core_indicator_id => total_ind_id,
              :sort_order => 4, :visible => true, :has_openlayers_rule_value => false)
            # - precinct relationship
            EventIndicatorRelationship.create(:event_id => event.id, :core_indicator_id => missing.id, :related_core_indicator_id => missing.id,
              :sort_order => 1, :visible => true, :has_openlayers_rule_value => true)
            EventIndicatorRelationship.create(:event_id => event.id, :core_indicator_id => missing.id, :related_core_indicator_id => total_ind_id,
              :sort_order => 4, :visible => true, :has_openlayers_rule_value => false)
          end
        end
      end
    end
