class AddIdIndexes < ActiveRecord::Migration
  def self.up
  
    # These indexes were found by searching for AR::Base finds on your application
    # It is strongly recommanded that you will consult a professional DBA about your infrastucture and implemntation before
    # changing your database in that matter.
    # There is a possibility that some of the indexes offered below is not required and can be removed and not added, if you require
    # further assistance with your rails application, database infrastructure or any other problem, visit:
    #
    # http://www.railsmentors.org
    # http://www.railstutor.org
    # http://guides.rubyonrails.org
  
    add_index :core_indicators, :id
    add_index :pages, :id
    add_index :events, :id
    add_index :indicator_types, :id
    add_index :event_types, :id
    add_index :shapes, :id
    add_index :shape_types, :id
    add_index :page_translations, :id
    add_index :event_translations, :id
    add_index :indicator_type_translations, :id
    add_index :shape_type_translations, :id
    add_index :indicator_scales, :id
    add_index :users, :id
    add_index :event_indicator_relationships, :id
    add_index :indicators, :id
    add_index :indicator_translation_olds, :id
    add_index :shape_translations, :id
    add_index :event_custom_views, :id
    add_index :data, :id
    add_index :indicator_scale_translations, :id
    add_index :event_type_translations, :id
    add_index :datum_translations, :id
    add_index :core_indicator_translations, :id
  end

  def self.down
    remove_index :core_indicators, :id
    remove_index :pages, :id
    remove_index :events, :id
    remove_index :indicator_types, :id
    remove_index :event_types, :id
    remove_index :shapes, :id
    remove_index :shape_types, :id
    remove_index :page_translations, :id
    remove_index :event_translations, :id
    remove_index :indicator_type_translations, :id
    remove_index :shape_type_translations, :id
    remove_index :indicator_scales, :id
    remove_index :users, :id
    remove_index :event_indicator_relationships, :id
    remove_index :indicators, :id
    remove_index :indicator_translation_olds, :id
    remove_index :shape_translations, :id
    remove_index :event_custom_views, :id
    remove_index :data, :id
    remove_index :indicator_scale_translations, :id
    remove_index :event_type_translations, :id
    remove_index :datum_translations, :id
    remove_index :core_indicator_translations, :id
  end
end
