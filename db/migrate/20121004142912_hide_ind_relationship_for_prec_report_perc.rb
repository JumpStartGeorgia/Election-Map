class HideIndRelationshipForPrecReportPerc < ActiveRecord::Migration
  def up
		num = CoreIndicatorTranslation.where(:name => 'Precincts Reported (#)')
		perc = CoreIndicatorTranslation.where(:name => 'Precincts Reported (%)')

		EventIndicatorRelationship.where(:core_indicator_id => num.first.core_indicator_id,
				:related_core_indicator_id => perc.first.core_indicator_id).each do |relationship|
			relationship.visible = false
			relationship.save
		end
  end

  def down
		num = CoreIndicatorTranslation.where(:name => 'Precincts Reported (#)')
		perc = CoreIndicatorTranslation.where(:name => 'Precincts Reported (%)')

		EventIndicatorRelationship.where(:core_indicator_id => num.first.core_indicator_id,
				:related_core_indicator_id => perc.first.core_indicator_id).each do |relationship|
			relationship.visible = true
			relationship.save
		end
  end
end
