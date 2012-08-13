# encoding: utf-8
class UpdateTotalIndicatorName < ActiveRecord::Migration
  def up
    cits = CoreIndicatorTranslation.where(:core_indicator_id => 15)
		cit = cits.select{|x| x.locale == 'ka'}.first
    cit.name = 'აქტივობა (#)'
		cit.save

    cits = CoreIndicatorTranslation.where(:core_indicator_id => 16)
		cit = cits.select{|x| x.locale == 'ka'}.first
    cit.name = 'აქტივობა (%)'
		cit.save
  end

  def down
		# do nothing
  end
end
