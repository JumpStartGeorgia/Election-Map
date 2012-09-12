class CleanUpLiveDataTables < ActiveRecord::Migration
  def up
    remove_index :live_data1s, :indicator_id
    remove_index :live_data1s, :value
    drop_table :live_data1s

    remove_index :live_data1_translations, :name => "index_live_data1_trans_on_locale_and_common_id_and_common_name"
    remove_index :live_data1_translations, :name => "index_live_data1_translations_on_live_data1_id"
    remove_index :live_data1_translations, :name => "index_live_data1_translations_on_locale"
    drop_table :live_data1_translations

    remove_index :live_data_statuses, :live_model
    remove_index :live_data_statuses, :inactive_model
    drop_table :live_data_statuses

		rename_table :live_data2s, :live_data
  end

  def down
		rename_table :live_data, :live_data2s
  end
end
