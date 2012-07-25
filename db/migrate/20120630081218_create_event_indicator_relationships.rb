class CreateEventIndicatorRelationships < ActiveRecord::Migration
  def change
    create_table :event_indicator_relationships do |t|
      t.integer :event_id, :null => false
      t.integer :indicator_type_id
      t.integer :core_indicator_id
      t.integer :related_indicator_type_id
      t.integer :related_core_indicator_id
      t.integer :sort_order, :null => false

      t.timestamps
    end
    
		add_index :event_indicator_relationships, :event_id
		add_index :event_indicator_relationships, :indicator_type_id
		add_index :event_indicator_relationships, :core_indicator_id
		add_index :event_indicator_relationships, :related_core_indicator_id
		add_index :event_indicator_relationships, :related_indicator_type_id
  end
end
