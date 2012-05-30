class AddDataTranslationFields < ActiveRecord::Migration
  def up

    Datum.create_translation_table! :common_id => :string, :common_name => :string
		add_index :datum_translations, :common_id
		add_index :datum_translations, :common_name
		
		# rename columns in data table, but not delete
		rename_column :data, :common_id, :common_id_old
		rename_column :data, :common_name, :common_name_old
		remove_index :data, :common_id
		remove_index :data, :common_name

		# move common_x records from data to data translations
# commented this out for there are ~ 500,000 records and it would take hours.  Only takes a few minutes with sql query
=begin
		DatumTranslation.delete_all
		Datum.all.each do |datum|
			I18n.available_locales.each do |locale|
				datum.datum_translations.create(:locale => locale, :common_id => datum.common_id_old, :common_name => datum.common_name_old)
			end
		end
=end
  end

  def down
		# rename columns in data table
		rename_column :data, :common_id_old, :common_id
		rename_column :data, :common_name_old, :common_name
		add_index :data, :common_id
		add_index :data, :common_name

		# data is still in the data common_x fields, so do not need to repopulate

		remove_index :datum_translations, :common_id
		remove_index :datum_translations, :common_name
    Datum.drop_translation_table!    
  end
end
