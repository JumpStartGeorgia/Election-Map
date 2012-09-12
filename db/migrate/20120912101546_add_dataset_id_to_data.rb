class AddDatasetIdToData < ActiveRecord::Migration
  def change

    remove_index :live_data, :name => "index_live_data2s_on_indicator_id"
    remove_index :live_data, :name => "index_live_data2s_on_value"
    remove_index :live_data, :name => "index_live_data2_en_common_id_and_common_name"
    remove_index :live_data, :name => "index_live_data2_ka_common_id_and_common_name"

		add_column :live_data, :live_data_set_id, :integer

    add_index :live_data, [:live_data_set_id, :indicator_id], :name => 'index_live_data_ids'
    add_index :live_data, :value
    add_index :live_data, ["en_common_id", "en_common_name"], :name => "index_live_data_en_common"
    add_index :live_data, ["ka_common_id", "ka_common_name"], :name => "index_live_data_ka_common"

  end
end
