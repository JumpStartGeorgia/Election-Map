class CreateUniqueShapeNames < ActiveRecord::Migration
  def up
    create_table :unique_shape_names do |t|
      t.integer :shape_type_id

      t.timestamps
    end

    add_index :unique_shape_names, :shape_type_id

    UniqueShapeName.create_translation_table! :common_id => :string, :common_name => :string, :summary => :text
    add_index :unique_shape_name_translations, :common_name
  end

  def down
    remove_index :unique_shape_name_translations, :common_name
    remove_index :unique_shape_names, :shape_type_id
    drop_table :unique_shape_names
    UniqueShapeName.drop_translation_table!    
  end


end
