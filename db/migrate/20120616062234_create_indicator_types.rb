class CreateIndicatorTypes < ActiveRecord::Migration
  def self.up
    create_table :indicator_types do |t|
      t.boolean :has_summary, :default => false

      t.timestamps
    end
    
    IndicatorType.create_translation_table! :name => :string, :description => :string
    
    add_column :indicators, :indicator_type_id, :integer, :default => 2 # make default value 'political results'
    add_index :indicators, :indicator_type_id

		puts "IMPORTANT - please update the indicator_type_id value in the indicators table.  The default value was set to 2 - political results."
  end
  def self.down
    drop_table :indicator_types
    IndicatorType.drop_translation_table!    
    remove_index :indicators, :indicator_type_id
    remove_column :indicators, :indicator_type_id
  end
end
