class RemoveShape2s < ActiveRecord::Migration
  def up

		remove_index "shape2s", :name => "index_shapes_on_ancestry"
		remove_index "shape2s", :name => "index_shapes_on_shape_type_id"
		remove_index "shape2s", :name => "index_shapes_en_common_id_and_common_name"
		remove_index "shape2s", :name => "index_shapes_ka_common_id_and_common_name"

    drop_table :shape2s

  end

  def down
		# do nothing
  end
end
