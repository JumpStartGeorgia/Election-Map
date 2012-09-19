class AddShapePrecinctsCount < ActiveRecord::Migration
  def up
		# add flag to shape types to indicate if type is a precinct
		add_column :shape_types, :is_precinct, :boolean, :default => false
		add_index :shape_types, :is_precinct
    connection = ActiveRecord::Base.connection()
    connection.execute("update shape_types set is_precinct = 1 where id in (4,6,8,10)")

		# add flag to shapes to record how many precincts are contained within shape
		add_column :shapes, :num_precincts, :integer

  end

  def down
		remove_index :shape_types, :is_precinct
		remove_column :shape_types, :is_precinct
		remove_column :shape, :num_precincts
  end
end
