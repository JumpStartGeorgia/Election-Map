class CreatePrecinctReportedIndicators < ActiveRecord::Migration
  def up
		core = CoreIndicator.create(:indicator_type_id => 2, :number_format => nil)
		core.core_indicator_translation.create(:locale => 'en', :name => 'Precincts Reported (#)', :name_abbrv => 'Precincts Reported (#)', :description => 'Precincts Reported (#)')
		core.core_indicator_translation.create(:locale => 'ka', :name => 'უბნებმა მოგვაწოდეს ინფორმაცია (#)', :name_abbrv => 'უბნებმა მოგვაწოდეს ინფორმაცია (#)', :description => 'უბნებმა მოგვაწოდეს ინფორმაცია (#)')

		core = CoreIndicator.create(:indicator_type_id => 2, :number_format => nil)
		core.core_indicator_translation.create(:locale => 'en', :name => 'Precincts Reported (%)', :name_abbrv => 'Precincts Reported (%)', :description => 'Precincts Reported (%)')
		core.core_indicator_translation.create(:locale => 'ka', :name => 'უბნებმა მოგვაწოდეს ინფორმაცია (%)', :name_abbrv => 'უბნებმა მოგვაწოდეს ინფორმაცია (%)', :description => 'უბნებმა მოგვაწოდეს ინფორმაცია (%)')
  end

  def down
		trans = CoreIndicatorTranslation.where("name like 'precincts reported%'")
		if trans && !trans.empty?
			trans.each do |x|
				CoreIndicator.find(x.core_indicator_id).destroy_all
			end
		end
  end
end
