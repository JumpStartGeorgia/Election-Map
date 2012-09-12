class AddDatasetIdToData < ActiveRecord::Migration
  def up

    remove_index :live_data, :name => "index_live_data2s_on_indicator_id"
    remove_index :live_data, :name => "index_live_data2s_on_value"
    remove_index :live_data, :name => "index_live_data2_en_common_id_and_common_name"
    remove_index :live_data, :name => "index_live_data2_ka_common_id_and_common_name"

		add_column :live_data, :live_dataset_id, :integer

    add_index :live_data, [:live_dataset_id, :indicator_id], :name => 'index_live_data_ids'
    add_index :live_data, :value
    add_index :live_data, ["en_common_id", "en_common_name"], :name => "index_live_data_en_common"
    add_index :live_data, ["ka_common_id", "ka_common_name"], :name => "index_live_data_ka_common"

  end

  def down

    remove_index :live_data, :name => 'index_live_data_ids'
    remove_index :live_data, :value
    remove_index :live_data, :name => "index_live_data_en_common"
    remove_index :live_data, :name => "index_live_data_ka_common"

		remove_column :live_data, :live_dataset_id

    add_index :live_data, :indicator_id, :name => "index_live_data2s_on_indicator_id"
    add_index :live_data, :value, :name => "index_live_data2s_on_value"
    add_index :live_data, [:en_common_id, :en_common_name], :name => "index_live_data2_en_common_id_and_common_name"
    add_index :live_data, [:ka_common_id, :ka_common_name], :name => "index_live_data2_ka_common_id_and_common_name"


  end
end
