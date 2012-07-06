class AddQueryIndexes < ActiveRecord::Migration
	# add indexes for columns that are used in the following capacity in queries
	# - foreign keys; sorting; where clause; group by clause

  def up
=begin
		add_index :events, :event_date
		add_index :event_indicator_relationships, :sort_order
		add_index :event_indicator_translations, :name_abbrv
		add_index :indicator_type_translations, :name
=end
#		add_index :shapes, [:shape_type_id, :geometry] # can't do this because geo is text
		add_index :shape_translations, [:locale, :common_id, :common_name]
		add_index :datum_translations, [:locale, :common_id, :common_name]
		add_index :core_indicators, [:id, :indicator_type_id]
		add_index :core_indicator_translations, [:locale, :name]
		add_index :indicators, [:event_id, :shape_type_id]
  end

  def down
		remove_index :events, :event_date
		remove_index :event_indicator_relationships, :sort_order
		remove_index :event_indicator_translations, :name_abbrv
		remove_index :indicator_type_translations, :name
#		remove_index :shapes, [:shape_type_id, :geometry]
		remove_index :shape_translations, [:locale, :common_id, :common_name]
		remove_index :datum_translations, [:locale, :common_id, :common_name]
		remove_index :core_indicators, [:id, :indicator_type_id]
		remove_index :core_indicator_translations, [:locale, :name]
		remove_index :indicators, [:event_id, :shape_type_id]
  end
end
