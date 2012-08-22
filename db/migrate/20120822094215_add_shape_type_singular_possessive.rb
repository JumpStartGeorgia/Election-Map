# encoding: utf-8

class AddShapeTypeSingularPossessive < ActiveRecord::Migration
  def up
		add_column :shape_type_translations, :name_singular_possessive, :string

		# add values
		ShapeTypeTranslation.transaction do
			# for english, it is same as singular
		  stt = ShapeTypeTranslation.where(:locale => 'en')
			stt.each do |trans|
				trans.name_singular_possessive = trans.name_singular
				trans.save
			end


			# ka
		  stts = ShapeTypeTranslation.where(:locale => 'ka')

			trans = stts.select{|x| x.name_singular == 'ქვეყანა'}.first
			trans.name_singular_possessive = 'ქვეყნის'
			trans.save

			trans = stts.select{|x| x.name_singular == 'რეგიონი'}.first
			trans.name_singular_possessive = 'რეგიონის'
			trans.save

			trans = stts.select{|x| x.name_singular == 'ოლქი'}.first
			trans.name_singular_possessive = 'ოლქის'
			trans.save

			# changing precinct name
			trans = stts.select{|x| x.name_singular == 'საუბნო'}.first
			trans.name_singular = 'უბანი'
			trans.name_singular_possessive = 'უბნის'
			trans.name_plural = 'უბნები'
			trans.save

			# fix maj spelling
			trans = stts.select{|x| x.name_singular == 'მაჟორიტარიული ოლქი'}.first
			trans.name_singular = 'მაჟორიტარული ოლქი'
			trans.name_singular_possessive = 'მაჟორიტარული ოლქის'
			trans.name_plural = 'მაჟორიტარული ოლქები'
			trans.save

			# changing precinct name
			trans = stts.select{|x| x.name_singular == 'მაჟორიტარიული საუბნო'}.first
			trans.name_singular = 'მაჟორიტარული უბანი'
			trans.name_singular_possessive = 'მაჟორიტარული უბნის'
			trans.name_plural = 'მაჟორიტარული უბნები'
			trans.save

			# fix tbilisi name
			trans = stts.select{|x| x.name_singular == 'თბილისი ოლქი'}.first
			trans.name_singular = 'თბილისი ოლქი'
			trans.name_singular_possessive = 'თბილისის ოლქის'
			trans.name_plural = 'თბილისის ოლქები'
			trans.save

			# changing precinct name
			trans = stts.select{|x| x.name_singular == 'თბილისი საუბნო'}.first
			trans.name_singular = 'თბილისის უბანი'
			trans.name_singular_possessive = 'თბილისის უბნის'
			trans.name_plural = 'თბილისის უბნები'
			trans.save

			# fix maj spelling
			trans = stts.select{|x| x.name_singular == 'მაჟორიტარიული თბილისი ოლქი'}.first
			trans.name_singular = 'მაჟორიტარული თბილისის ოლქი'
			trans.name_singular_possessive = 'მაჟორიტარული თბილისის ოლქის'
			trans.name_plural = 'მაჟორიტარული თბილისის ოლქები'
			trans.save

			# changing precinct name
			trans = stts.select{|x| x.name_singular == 'მაჟორიტარიული თბილისი საუბნო'}.first
			trans.name_singular = 'მაჟორიტარული თბილისის უბანი'
			trans.name_singular_possessive = 'მაჟორიტარული თბილისის უბნის'
			trans.name_plural = 'მაჟორიტარული თბილისის უბნები'
			trans.save

		end
  end

  def down
		remove_column :shape_type_translations, :name_singular_possessive
  end
end
