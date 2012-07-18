class RemoveOldFields < ActiveRecord::Migration
  def up
		remove_index :data, :name => "common_id_old"
		remove_column :data, :value_old
		remove_column :data, :common_id_old
		remove_column :data, :common_name_old

		remove_column :indicator_scales, :color_old

		remove_index "indicator_translation_olds", :name => "index_indicator_translations_on_indicator_id"
		remove_index "indicator_translation_olds", :name => "index_indicator_translations_on_locale"
		remove_index "indicator_translation_olds", :name => "index_indicator_translations_on_name"
		drop_table :indicator_translation_olds

		remove_index :indicators, :name => "index_indicators_on_indicator_type_id"
		remove_column :indicators, :number_format_old
		remove_column :indicators, :indicator_type_id_old

		remove_index :shapes, :name => "common_id_old"
		remove_column :shapes, :common_id_old
		remove_column :shapes, :common_name_old
	
  end

  def down
		add_column :data, :value_old, :text
		add_column :data, :common_id_old, :string
		add_column :data, :common_name_old, :string
		add_index "data", ["common_id_old", "common_name_old"], :name => "common_id_old"

		add_colum :indicator_scales, :color_old, :string

		create_table "indicator_translation_olds", :force => true do |t|
		  t.integer  "indicator_id"
		  t.string   "locale"
		  t.string   "name"
		  t.string   "name_abbrv"
		  t.datetime "created_at"
		  t.datetime "updated_at"
		  t.text     "description"
		end
		add_index "indicator_translation_olds", ["id"]
		add_index "indicator_translation_olds", ["indicator_id"]
		add_index "indicator_translation_olds", ["locale"]
		add_index "indicator_translation_olds", ["name"]

		add_column :indicators, :number_format_old, :string
		add_column :indicators, :indicator_type_id_old, :integer
		add_index :indicators, :indicator_type_id_old

		add_column :shapes, :common_id_old, :string
		add_column :shapes, :common_name_old, :string
		add_index :shapes, [:common_id_old, :common_name_old], :name => "common_id_old"


  end
end
