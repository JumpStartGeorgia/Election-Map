class AddMoreIndexes < ActiveRecord::Migration
  def up
    add_index :event_translations, :name
    add_index :event_type_translations, :name
    add_index :indicator_translations, :name
    add_index :indicator_scale_translations, :name
    add_index :shape_translations, :name
    add_index :shape_type_translations, :name
    add_index :data, :common_name
    add_index :shapes, :common_name
  end

  def down
    remove_index :event_translations, :name
    remove_index :event_type_translations, :name
    remove_index :indicator_translations, :name
    remove_index :indicator_scale_translations, :name
    remove_index :shape_translations, :name
    remove_index :shape_type_translations, :name
    remove_index :data, :common_name
    remove_index :shapes, :common_name
  end
end
