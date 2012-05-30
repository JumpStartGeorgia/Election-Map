class AddShapeTranslationFields < ActiveRecord::Migration
  def up

		add_column :shape_translations, :common_id, :string
		add_column :shape_translations, :common_name, :string
		remove_column :shape_translations, :name
		add_index :shape_translations, :common_id
		add_index :shape_translations, :common_name

		# rename columns in shape table, but not delete
		rename_column :shapes, :common_id, :common_id_old
		rename_column :shapes, :common_name, :common_name_old
		remove_index :shapes, :common_id
		remove_index :shapes, :common_name

		# move common_x records from shapes to shape translations
		ShapeTranslation.delete_all
		Shape.all.each do |shape|
			I18n.available_locales.each do |locale|
				shape.shape_translations.create(:locale => locale, :common_id => shape.common_id_old, :common_name => shape.common_name_old)
			end
		end

  end

  def down
		# rename columns in shape table
		rename_column :shapes, :common_id_old, :common_id
		rename_column :shapes, :common_name_old, :common_name
		add_index :shapes, :common_id
		add_index :shapes, :common_name

		# data is still in the shape common_x fields, so do not need to repopulate
		
		# drop shape translation columns
		remove_column :shape_translations, :common_id
		remove_column :shape_translations, :common_name
		remove_index :shape_translations, :common_id
		remove_index :shape_translations, :common_name
		add_column :shape_translations, :name, :string

  end
end
