class CreateLiveData1s < ActiveRecord::Migration
  def up

    create_table "live_data1s", :force => true do |t|
      t.integer  "indicator_id"
      t.decimal  "value",        :precision => 16, :scale => 4

      t.timestamps
    end

    add_index :live_data1s, :indicator_id
    add_index :live_data1s, :value

    LiveData1.create_translation_table! :common_id => :string, :common_name => :string
    add_index :live_data1_translations, ["locale", "common_id", "common_name"], :name => "index_live_data1_trans_on_locale_and_common_id_and_common_name"

  end

  def down
    remove_index :live_data1s, :indicator_id
    remove_index :live_data1s, :value
    drop_table :live_data1s

    remove_index :live_data1_translations, :name => "index_live_data1_trans_on_locale_and_common_id_and_common_name"
    LiveData1.drop_translation_table!    
  end
end
