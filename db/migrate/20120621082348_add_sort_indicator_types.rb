class AddSortIndicatorTypes < ActiveRecord::Migration
  def up
		add_column :indicator_types, :sort_order, :integer, :default => 1
		add_index :indicator_types, :sort_order
		
		# since default is 1, political results is fine.
		# update indicator indicator type to 2
		ind_type = IndicatorType.find(1)
		ind_type.sort_order = 2
		ind_type.save

		puts "Set sort order of political results to 1 and indicators to 2"
  end

  def down
		remove_column :indicator_types, :sort_order
  end
end
