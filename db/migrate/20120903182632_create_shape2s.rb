class CreateShape2s < ActiveRecord::Migration
  def change
    create_table :shape2s do |t|
      t.integer  "shape_type_id"
      t.text     "geometry",      :limit => 2147483647
      t.string   "en_common_id"
      t.string   "en_common_name"
      t.string   "ka_common_id"
      t.string   "ka_common_name"
      t.string   "ancestry"
      
      t.timestamps
    end

  add_index "shape2s", ["ancestry"], :name => "index_shapes_on_ancestry"
  add_index "shape2s", ["shape_type_id"], :name => "index_shapes_on_shape_type_id"
  add_index "shape2s", ["en_common_id", "en_common_name"], :name => "index_shapes_en_common_id_and_common_name"
  add_index "shape2s", ["ka_common_id", "ka_common_name"], :name => "index_shapes_ka_common_id_and_common_name"

  end
end
