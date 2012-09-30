# encoding: utf-8
class UpdateDuplicationName < ActiveRecord::Migration
  def up
		trans = CoreIndicatorTranslation.where(:core_indicator_id => 12)

		# en
		record = trans.select{|x| x.locale == 'en'}.first
		record.name = 'Number of potential voter duplications'
		record.name_abbrv = 'Potential Duplications'
		record.description = 'Number of potential voter duplications'
		record.save

		# ka
		record = trans.select{|x| x.locale == 'ka'}.first
		record.name = 'ამომრჩეველთა შორის პოტენციური დუბლირების რაოდენობა'
		record.name_abbrv = 'პოტენციური დუბლირება'
		record.description = 'ამომრჩეველთა შორის პოტენციური დუბლირების რაოდენობა'
		record.save
  end

  def down
		trans = CoreIndicatorTranslation.where(:core_indicator_id => 12)

		# en
		record = trans.select{|x| x.locale == 'en'}.first
		record.name = 'Number of voter duplications'
		record.name_abbrv = 'Duplications'
		record.description = 'Number of voter duplications'
		record.save

		# ka
		record = trans.select{|x| x.locale == 'ka'}.first
		record.name = 'დუბლირებულ ამომრჩეველთა რაოდენობა'
		record.name_abbrv = 'დუბლირებული'
		record.description = 'დუბლირებულ ამომრჩეველთა რაოდენობა'
		record.save
  end
end
