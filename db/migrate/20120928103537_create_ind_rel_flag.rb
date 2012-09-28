class CreateIndRelFlag < ActiveRecord::Migration
  def up
		add_column :event_indicator_relationships, :has_openlayers_rule_value, :boolean, :default => false
		add_column :event_indicator_relationships, :visible, :boolean, :default => true
  end

  def down
		remove_column :event_indicator_relationships, :has_openlayers_rule_value
		remove_column :event_indicator_relationships, :visible
  end
end
