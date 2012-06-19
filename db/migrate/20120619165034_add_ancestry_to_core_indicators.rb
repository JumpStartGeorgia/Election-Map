class AddAncestryToCoreIndicators < ActiveRecord::Migration
  def change
    add_column :core_indicators, :ancestry, :string
    add_index :core_indicators, :ancestry
  end
end
