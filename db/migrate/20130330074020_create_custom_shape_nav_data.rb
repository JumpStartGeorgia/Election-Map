class CreateCustomShapeNavData < ActiveRecord::Migration
  def up

    CustomShapeNavigation.transaction do
      # for each event with custom view, 
      # create custom shape nav for country and tbilisi
      EventCustomView.all.each do |custom_view|
        # country
        custom = CustomShapeNavigation.create(
          :event_id => custom_view.event_id,
          :shape_type_id => custom_view.shape_type_id,
          :sort_order => 1,
          :always_visible => true
        )  

        custom.custom_shape_navigation_translations.create(
          :locale => 'en',
          :link_text => 'Country View'
        )
        custom.custom_shape_navigation_translations.create(
          :locale => 'ka',
          :link_text => 'Country View'
        )


        if custom_view.event_id == 15
          # create nav for majoritarian levels
          # major district
          custom = CustomShapeNavigation.create(
            :event_id => custom_view.event_id,
            :shape_type_id => 3,
            :show_at_shape_type_id => 5,
            :sort_order => 2,
            :always_visible => false
          )  

          custom.custom_shape_navigation_translations.create(
            :locale => 'en',
            :link_text => 'Majoritarian District View'
          )
          custom.custom_shape_navigation_translations.create(
            :locale => 'ka',
            :link_text => 'Majoritarian District View'
          )

          # tbilisi
          custom = CustomShapeNavigation.create(
            :event_id => custom_view.event_id,
            :shape_type_id => 3,
            :show_at_shape_type_id => 7,
            :sort_order => 2,
            :always_visible => false
          )  

          custom.custom_shape_navigation_translations.create(
            :locale => 'en',
            :link_text => 'Tbilisi View'
          )
          custom.custom_shape_navigation_translations.create(
            :locale => 'ka',
            :link_text => 'Tbilisi View'
          )

          # major tbilisi 
          custom = CustomShapeNavigation.create(
            :event_id => custom_view.event_id,
            :shape_type_id => 7,
            :show_at_shape_type_id => 9,
            :sort_order => 3,
            :always_visible => false
          )  

          custom.custom_shape_navigation_translations.create(
            :locale => 'en',
            :link_text => 'Majoritarian Tbilisi District View'
          )
          custom.custom_shape_navigation_translations.create(
            :locale => 'ka',
            :link_text => 'Majoritarian Tbilisi District View'
          )


        else
          # tbilisi
          custom = CustomShapeNavigation.create(
            :event_id => custom_view.event_id,
            :shape_type_id => 3,
            :sort_order => 2,
            :always_visible => false
          )  

          custom.custom_shape_navigation_translations.create(
            :locale => 'en',
            :link_text => 'Tbilisi View'
          )
          custom.custom_shape_navigation_translations.create(
            :locale => 'ka',
            :link_text => 'Tbilisi View'
          )

        end

      end 


      # create custom nav for adjara
      Event.where(:event_type_id => 4).each do |event|
        #adjara region
        custom = CustomShapeNavigation.create(
          :event_id => event.id,
          :shape_type_id => 2,
          :sort_order => 1,
          :always_visible => true
        )  

        custom.custom_shape_navigation_translations.create(
          :locale => 'en',
          :link_text => 'Adjara View'
        )
        custom.custom_shape_navigation_translations.create(
          :locale => 'ka',
          :link_text => 'Adjara View'
        )
      end

      # create custom nav for rest of events
      # tblisi mayor
      custom = CustomShapeNavigation.create(
        :event_id => 11,
        :shape_type_id => 3,
        :sort_order => 1,
        :always_visible => true
      )  

      custom.custom_shape_navigation_translations.create(
        :locale => 'en',
        :link_text => 'Tbilisi View'
      )
      custom.custom_shape_navigation_translations.create(
        :locale => 'ka',
        :link_text => 'Tbilisi View'
      )
      

    end
  end

  def down
    CustomShapeNavigation.delete_all
    CustomShapeNavigationTranslation.delete_all
  end
end
