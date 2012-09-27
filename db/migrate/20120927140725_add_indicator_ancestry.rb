class AddIndicatorAncestry < ActiveRecord::Migration
  def up
    add_column :indicators, :ancestry, :string
		add_index :indicators, :ancestry
  end

  def down
		remove_index :indicators, :ancestry
    remove_column :indicators, :ancestry
  end
end
