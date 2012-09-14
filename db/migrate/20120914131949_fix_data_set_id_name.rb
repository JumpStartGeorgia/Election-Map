class FixDataSetIdName < ActiveRecord::Migration
  def up
    remove_index :live_data, :name => 'index_live_data_ids'

		rename_column :live_data, :live_data_set_id, :data_set_id

    add_index :live_data, [:data_set_id, :indicator_id], :name => 'index_live_data_ids'
  end

  def down
    remove_index :live_data, :name => 'index_live_data_ids'

		rename_column :live_data, :data_set_id, :live_data_set_id

    add_index :live_data, [:livedata_set_id, :indicator_id], :name => 'index_live_data_ids'
  end
end
