class UpdateDataTable < ActiveRecord::Migration
  def up
    remove_index "data", :name => "index_data_on_indicator_id"

    add_column :data, :data_set_id, :integer
    add_column :data, :en_common_id, :string
    add_column :data, :en_common_name, :string
    add_column :data, :ka_common_id, :string
    add_column :data, :ka_common_name, :string


    add_index "data", ["data_set_id", "indicator_id"], :name => "index_data_ids"
    add_index "data", ["en_common_id", "en_common_name"], :name => "index_data_en_common"
    add_index "data", ["ka_common_id", "ka_common_name"], :name => "index_data_ka_common"
    
  end

  def down

    remove_index "data", :name => "index_data_ids"
    remove_index "data", :name => "index_data_en_common"
    remove_index "data", :name => "index_data_ka_common"

    remove_column :data, :data_set_id
    remove_column :data, :en_common_id
    remove_column :data, :en_common_name
    remove_column :data, :ka_common_id
    remove_column :data, :ka_common_name

    add_index "data", ["indicator_id"], :name => "index_data_on_indicator_id"

  end
end
