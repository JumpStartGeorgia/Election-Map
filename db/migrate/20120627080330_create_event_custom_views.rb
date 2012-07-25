class CreateEventCustomViews < ActiveRecord::Migration
  def change
    create_table :event_custom_views do |t|
      t.integer :event_id
      t.integer :shape_type_id
      t.integer :descendant_shape_type_id
      t.boolean :is_default_view, :default => false

      t.timestamps
    end

		add_index :event_custom_views, :event_id
		add_index :event_custom_views, :shape_type_id
		add_index :event_custom_views, :descendant_shape_type_id

  end
end
