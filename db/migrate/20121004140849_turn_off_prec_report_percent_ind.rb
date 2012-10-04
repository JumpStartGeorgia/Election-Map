class TurnOffPrecReportPercentInd < ActiveRecord::Migration
  def up
		trans = CoreIndicatorTranslation.where(:name => 'Precincts Reported (%)')

		# update all indicators with this core id to not be visible
		Indicator.where(:core_indicator_id => trans.first.core_indicator_id).each do |indicator|
			indicator.visible = false
			indicator.save
		end

  end

  def down
		trans = CoreIndicatorTranslation.where(:name => 'Precincts Reported (%)')

		# update all indicators with this core id to be visible
		Indicator.where(:core_indicator_id => trans.first.core_indicator_id).each do |indicator|
			indicator.visible = true
			indicator.save
		end
  end
end
