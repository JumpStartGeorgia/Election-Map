class RemoveDupIndex < ActiveRecord::Migration
  def up
    # duplicate id indexes
    remove_index :core_indicators, :id
    remove_index :core_indicator_translations, :id
    remove_index :data, :id
    remove_index :datum_translations, :id
    remove_index :event_custom_views, :id
    remove_index :event_indicator_relationships, :id
    remove_index :event_type_translations, :id
    remove_index :event_types, :id
    remove_index :event_translations, :id
    remove_index :events, :id
    remove_index :indicator_scale_translations, :id
    remove_index :indicator_scales, :id
    remove_index :indicator_type_translations, :id
    remove_index :indicator_types, :id
    remove_index :indicators, :id
    remove_index :page_translations, :id
    remove_index :pages, :id
    remove_index :shape_translations, :id
    remove_index :shape_type_translations, :id
    remove_index :shape_types, :id
    remove_index :shapes, :id
    remove_index :users, :id

    # group indexes together
    remove_index :event_indicator_relationships, :event_id
		remove_index :event_indicator_relationships, :indicator_type_id
		remove_index :event_indicator_relationships, :core_indicator_id
		add_index :event_indicator_relationships, [:event_id,:indicator_type_id], :name => "indicator_rltnshps_event_ind_type"
		add_index :event_indicator_relationships, [:event_id,:core_indicator_id], :name => "indicator_rltnshps_event_core_ind"

		remove_index :event_custom_views, :event_id
		remove_index :event_custom_views, :shape_type_id
		add_index :event_custom_views, [:event_id,:shape_type_id]

		remove_index :core_indicators, [:id, :indicator_type_id] # no longer need

		# group already exists
    remove_index :core_indicator_translations, :locale
    remove_index :core_indicator_translations, :name
    add_index :indicators, [:event_id, :shape_type_id, :core_indicator_id], :name => "inds_event_shape_type_core_ind"

    remove_index :indicators, [:event_id, :shape_type_id]
    remove_index :indicators, :event_id
    remove_index :indicators, :shape_type_id
    remove_index :indicators, :core_indicator_id

		remove_index :shape_type_translations, :locale
		remove_index :shape_type_translations, :name_singular
		add_index :shape_type_translations, [:locale,:name_singular]

		# group already exists
		remove_index :datum_translations, :locale
		remove_index :datum_translations, :common_id
		remove_index :datum_translations, :common_name

    # group already exists
		remove_index :shape_translations, :locale
		remove_index :shape_translations, :common_id
		remove_index :shape_translations, :common_name

    remove_index :event_custom_view_translations, :locale
    remove_index :event_custom_view_translations, :note
    add_index :event_custom_view_translations, [:locale, :note]


    remove_index :event_translations, :locale
    remove_index :event_translations, :name
    add_index :event_translations, [:locale, :name]

    remove_index :event_type_translations, :locale
    remove_index :event_type_translations, :name
    add_index :event_type_translations, [:locale, :name]

    remove_index :indicator_scale_translations, :locale
    remove_index :indicator_scale_translations, :name
    add_index :indicator_scale_translations, [:locale, :name]

    remove_index :indicator_translations, :locale
    remove_index :indicator_translations, :name
    add_index :indicator_translations, [:locale,:name]

    remove_index :indicator_type_translations, :locale
    add_index :indicator_type_translations, [:locale,:name]


		# drop unused tables
    remove_index :event_indicators, :event_id
    remove_index :event_indicators, :shape_type_id
    remove_index :event_indicators, :indicator_type_id
		drop_table :event_indicators

    remove_index :event_indicator_translations, :event_indicator_id
    remove_index :event_indicator_translations, :locale
    remove_index :event_indicator_translations, :name
    remove_index :event_indicator_translations, :name_abbrv
		drop_table :event_indicator_translations

		drop_table :locales
  end

  def down
    add_index :core_indicators, :id
    add_index :core_indicator_translations, :id
    add_index :data, :id
    add_index :datum_translations, :id
    add_index :event_custom_views, :id
    add_index :event_indicator_relationships, :id
    add_index :event_type_translations, :id
    add_index :event_types, :id
    add_index :event_translations, :id
    add_index :events, :id
    add_index :indicator_scale_translations, :id
    add_index :indicator_scales, :id
    add_index :indicator_type_translations, :id
    add_index :indicator_types, :id
    add_index :indicators, :id
    add_index :page_translations, :id
    add_index :pages, :id
    add_index :shape_translations, :id
    add_index :shape_type_translations, :id
    add_index :shape_types, :id
    add_index :shapes, :id
    add_index :users, :id

    add_index :event_indicator_relationships, :event_id
    add_index :event_indicator_relationships, :indicator_type_id
    add_index :event_indicator_relationships, :core_indicator_id
    remove_index :event_indicator_relationships, [:event_id,:indicator_type_id]
    remove_index :event_indicator_relationships, [:event_id,:core_indicator_id]

    add_index :event_custom_views, :event_id
    add_index :event_custom_views, :shape_type_id
    remove_index :event_custom_views, [:event_id,:shape_type_id]

    add_index :core_indicators, [:id, :indicator_type_id]

    add_index :core_indicator_translations, :locale
    add_index :core_indicator_translations, :name

    add_index :indicators, [:event_id, :shape_type_id]
    remove_index :indicators, [:event_id, :shape_type_id, :core_indicator_id]
    remove_index :indicators, :core_indicator_id

    add_index :shape_type_translations, :locale
    add_index :shape_type_translations, :name_singular
    remove_index :shape_type_translations, [:locale,:name_singular]

    add_index :datum_translations, :locale
    add_index :datum_translations, :common_id
    add_index :datum_translations, :common_name

    add_index :shape_translations, :locale
    add_index :shape_translations, :common_id
    add_index :shape_translations, :common_name

    add_index :event_custom_view_translations, :locale
    add_index :event_custom_view_translations, :note
    remove_index :event_custom_view_translations, [:locale, :note]

    add_index :event_translations, :locale
    add_index :event_translations, :name
    remove_index :event_translations, [:locale, :name]

    add_index :event_type_translations, :locale
    add_index :event_type_translations, :name
    remove_index :event_type_translations, [:locale, :name]

    add_index :indicator_scale_translations, :locale
    add_index :indicator_scale_translations, :name
    remove_index :indicator_scale_translations, [:locale, :name]

    add_index :indicator_translations, :locale
    add_index :indicator_translations, :name
    remove_index :indicator_translations, [:locale,:name]

    add_index :indicator_type_translations, :locale
    remove_index :indicator_type_translations, [:locale,:name]
  end
end
