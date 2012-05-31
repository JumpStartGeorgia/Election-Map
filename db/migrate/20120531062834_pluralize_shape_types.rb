class PluralizeShapeTypes < ActiveRecord::Migration
  def change
		remove_index :shape_type_translations, :name
		rename_column :shape_type_translations, :name, :name_singular
		add_column :shape_type_translations, :name_plural, :string
		add_index :shape_type_translations, :name_singular
		add_index :shape_type_translations, :name_plural
		puts "please update the seed file and run it to add the plural names"
  end
end
