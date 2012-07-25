class ChangeDataValueType < ActiveRecord::Migration
  def up
    # change value column from text to decimal
    rename_column :data, :value, :value_old
    add_column :data, :value, :decimal, :precision => 16, :scale => 4
    add_index :data, :value
    
    # move data from value_old to value
    # if the data in value_old is a string (e.g., NULL), replace with null
    connection = ActiveRecord::Base.connection()
    connection.execute("update data set value = if(value_old regexp '[[:alpha:]]+', null, cast(value_old as decimal(16,4)))")    
  end

  def down
    remove_index :data, :value
    remove_column :data, :value
    rename_column :data, :value_old, :value
  end
end
