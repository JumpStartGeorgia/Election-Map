class AddIndicatorVisiblity < ActiveRecord::Migration
  def up
		add_column :indicators, :visible, :boolean, :default => true
		add_index :indicators, :visible
  end

  def down
		remove_index :indicators, :visible
		remove_column :indicators, :visible, :boolean
  end
end
