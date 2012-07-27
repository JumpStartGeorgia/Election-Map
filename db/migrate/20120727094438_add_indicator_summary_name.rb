# encoding: utf-8

class AddIndicatorSummaryName < ActiveRecord::Migration
  def up
		add_column :indicator_type_translations, :summary_name, :string

		# now update the names of the indicator types and add summary name
		indicator_type_translations = IndicatorTypeTranslation.where(:locale => 'en')

    it = indicator_type_translations.select{|x| x.indicator_type_id == 1 }.first
    it.name = 'Other'
		it.summary_name = 'Other'
		it.save

    it = indicator_type_translations.select{|x| x.indicator_type_id == 2 }.first
    it.name = 'Results'
		it.summary_name = 'Overall Results'
		it.save

		indicator_type_translations = IndicatorTypeTranslation.where(:locale => 'ka')

    it = indicator_type_translations.select{|x| x.indicator_type_id == 1 }.first
    it.name = 'სხვა'
		it.summary_name = 'სხვა'
		it.save

    it = indicator_type_translations.select{|x| x.indicator_type_id == 2 }.first
    it.name = 'შედეგი'
		it.summary_name = 'საერთო შედეგები'
		it.save

  end

  def down
		remove_column :indicator_type_translations, :summary_name
  end
end
