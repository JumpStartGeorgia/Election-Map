class CreateCoreIndicators < ActiveRecord::Migration
  def up
		unless table_exists? :core_indicators
		  create_table :core_indicators do |t|
		    t.integer :indicator_type_id
		    t.string :number_format

		    t.timestamps
		  end
			add_index :core_indicators, :indicator_type_id
		end
	
		unless table_exists? :core_indicator_translations
		  CoreIndicator.create_translation_table! :name => :string, :name_abbrv => :string, :description => :text
			add_index :core_indicator_translations, :name
			add_index :core_indicator_translations, :name_abbrv
		end

		unless column_exists? :indicators, :core_indicator_id
			add_column :indicators, :core_indicator_id, :integer
			add_index :indicators, :core_indicator_id
		end

		# rename old columns in indicators table
		unless !column_exists? :indicators, :indicator_type_id
			rename_column :indicators, :indicator_type_id, :indicator_type_id_old
		end
		unless !column_exists? :indicators, :number_format
			rename_column :indicators, :number_format, :number_format_old
		end
		
		# rename old indicator translations table
		unless !table_exists? :indicator_translations
			rename_table :indicator_translations, :indicator_translation_olds
		end

		# migrate unique indicators to the core table
		puts "Inserting unique indicators into the new core_indicators table..."
		CoreIndicator.destroy_all
		uniq_indicators = IndicatorTranslationOld.select("distinct name").where(:locale => "en")
		uniq_indicators.each do |uniq_indicator|
			# get the first indicator that has this name
			ind_trans = IndicatorTranslationOld.where(["locale = 'en' and name = ?", uniq_indicator.name]).first
			ind = Indicator.find(ind_trans.indicator_id)

			# now add this indicator to the core indicators table
			core = CoreIndicator.create(:indicator_type_id => ind.indicator_type_id_old, :number_format => ind.number_format_old)
			ind.indicator_translation_olds.each do |trans|
				I18n.available_locales.each do |locale|
					if trans.locale == locale.to_s
						core.core_indicator_translations.create(:locale => locale, :name => trans.name, :name_abbrv => trans.name_abbrv, :description => trans.description)
						break
					end
				end
			end
		end
		puts "Unique indicators have been inserted into the new core_indicators table."

		# now insert the core indicator id into the indicators table
		puts "Inserting core indicator id into the indicators table..."
		cores = CoreIndicator.includes(:core_indicator_translations).where("core_indicator_translations.locale = 'en'")
		cores.each do |core|
			inds = Indicator.includes(:indicator_translation_olds).where(["indicator_translation_olds.locale = 'en' and indicator_translation_olds.name = ?", core.core_indicator_translations[0].name])
			
			# add the core indicator id
			inds.each do |ind|
				ind.core_indicator_id = core.id
				ind.save
			end
		end
		puts "Core indicator ids have been inserted into the indicators table."

  end

	def down
		unless table_exists? :core_indicators
	    drop_table :core_indicators
		end
		unless table_exists? :core_indicator_translations
	    CoreIndicator.drop_translation_table!    
		end

		unless column_exists? :indicators, :core_indicator_id
			remove_index :indicators, :core_indicator_id
			remove_column :indicators, :core_indicator_id
		end
		unless column_exists? :indicators, :number_format
			rename_column :indicators, :indicator_type_id_old, :indicator_type_id
		end
		unless column_exists? :indicators, :number_format
			rename_column :indicators, :number_format_old, :number_format
		end
		unless table_exists? :indicator_translations
			rename_table :indicator_translation_olds, :indicator_translations
		end
	end
end
