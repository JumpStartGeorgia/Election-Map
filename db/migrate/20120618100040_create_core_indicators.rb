class CreateCoreIndicators < ActiveRecord::Migration
  def up

    create_table :core_indicators do |t|
      t.integer :indicator_type_id
      t.string :number_format

      t.timestamps
    end
		add_index :core_indicators, :indicator_type_id

    CoreIndicator.create_translation_table! :name => :string, :name_abbrv => :string, :description => :text
		add_index :core_indicator_translations, :name
		add_index :core_indicator_translations, :name_abbrv

		add_column :indicators, :core_indicator_id, :integer
		add_index :indicators, :core_indicator_id

		# migrate unique indicators to the core table
		puts "Inserting unique indicators into the new core_indicators table..."
		CoreIndicator.destroy_all
		uniq_indicators = IndicatorTranslation.select("distinct name").where(:locale => "en")
		uniq_indicators.each do |uniq_indicator|
			# get the first indicator that has this name
			ind_trans = IndicatorTranslation.where(["locale = 'en' and name = ?", uniq_indicator.name]).first
			ind = Indicator.find(ind_trans.indicator_id)

			# now add this indicator to the core indicators table
			core = CoreIndicator.create(:indicator_type_id => ind.indicator_type_id, :number_format => ind.number_format)
			ind.indicator_translations.each do |trans|
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
			inds = Indicator.includes(:indicator_translations).where(["indicator_translations.locale = 'en' and indicator_translations.name = ?", core.core_indicator_translations[0].name])
			
			# add the core indicator id
			inds.each do |ind|
				ind.core_indicator_id = core.id
				ind.save
			end
		end
		puts "Core indicator ids have been inserted into the indicators table."

  end

	def down
    drop_table :core_indicators
    CoreIndicator.drop_translation_table!    

		remove_index :indicators, :core_indicator_id
		remove_column :indicators, :core_indicator_id
	end
end
