class CreateLiveData2s < ActiveRecord::Migration
  def up

    create_table "live_data2s", :force => true do |t|
      t.integer  "indicator_id"
      t.decimal  "value",        :precision => 16, :scale => 4
      t.string   "en_common_id"
      t.string   "en_common_name"
      t.string   "ka_common_id"
      t.string   "ka_common_name"
      t.timestamps
    end

    add_index :live_data2s, :indicator_id
    add_index :live_data2s, :value
    add_index :live_data2s, ["en_common_id", "en_common_name"], :name => "index_live_data2_en_common_id_and_common_name"
    add_index :live_data2s, ["ka_common_id", "ka_common_name"], :name => "index_live_data2_ka_common_id_and_common_name"

  end

  def down
    remove_index :live_data2s, :indicator_id
    remove_index :live_data2s, :value
    remove_index :live_data2s, :name => "index_live_data2_en_common_id_and_common_name"
    remove_index :live_data2s, :name => "index_live_data2_ka_common_id_and_common_name"
    drop_table :live_data2s
  end
end
