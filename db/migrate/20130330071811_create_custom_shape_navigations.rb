class CreateCustomShapeNavigations < ActiveRecord::Migration
  def self.up
    create_table :custom_shape_navigations do |t|
      t.integer :event_id
      t.integer :shape_type_id
      t.integer :sort_order, :default => 1
      t.boolean :always_visible, :default => true

      t.timestamps
    end

    add_index :custom_shape_navigations, [:event_id, :sort_order], :name => 'idx_custom_shapes_event'

    CustomShapeNavigation.create_translation_table! :link_text => :string    

  end

  def self.down
    drop_table :custom_shape_navigations
    CustomShapeNavigation.drop_translation_table!    
  end
end
