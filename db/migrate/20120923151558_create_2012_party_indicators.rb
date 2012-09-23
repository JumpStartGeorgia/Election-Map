# encoding: utf-8
class Create2012PartyIndicators < ActiveRecord::Migration
  def up
		#free georgia
		core = CoreIndicator.create(:indicator_type_id => 2, :number_format => '%', :color => '#C26254')
		core.core_indicator_translations.create(:locale => 'en', :name => 'Free Georgia',
			:name_abbrv => 'Free Georgia',
			:description => 'Vote share Free Georgia (%)')
		core.core_indicator_translations.create(:locale => 'ka', :name => 'თავისუფალი საქართველო',
			:name_abbrv => 'თავისუფალი საქართველო',
			:description => 'ხმების გადანაწილება, თავისუფალი საქართველო (%)')

		# Public Movement
		core = CoreIndicator.create(:indicator_type_id => 2, :number_format => '%', :color => '#408a85')
		core.core_indicator_translations.create(:locale => 'en', :name => 'Public Movement',
			:name_abbrv => 'Public Movement',
			:description => 'Vote share Public Movement (%)')
		core.core_indicator_translations.create(:locale => 'ka', :name => 'სახალხო მოძრაობა',
			:name_abbrv => 'სახალხო მოძრაობა',
			:description => 'ხმების გადანაწილება, სახალხო მოძრაობა (%)')

		# People’s Party
		core = CoreIndicator.create(:indicator_type_id => 2, :number_format => '%', :color => '#b8afba')
		core.core_indicator_translations.create(:locale => 'en', :name => 'People\'s Party',
			:name_abbrv => 'People\'s Party',
			:description => 'Vote share People\'s Party (%)')
		core.core_indicator_translations.create(:locale => 'ka', :name => 'სახალხო პარტია',
			:name_abbrv => 'სახალხო პარტია',
			:description => 'ხმების გადანაწილება, სახალხო პარტია (%)')

		# Merab Kostava Society
		core = CoreIndicator.create(:indicator_type_id => 2, :number_format => '%', :color => '#6e658f')
		core.core_indicator_translations.create(:locale => 'en', :name => 'Merab Kostava Society',
			:name_abbrv => 'M. Kostava Society',
			:description => 'Vote share Merab Kostava Society (%)')
		core.core_indicator_translations.create(:locale => 'ka', :name => 'მერაბ კოსტავას საზოგადოება',
			:name_abbrv => 'კოსტავას საზოგადოება',
			:description => 'ხმების გადანაწილება, მერაბ კოსტავას საზოგადოება (%)')

		# Labour Council of Georgia
		core = CoreIndicator.create(:indicator_type_id => 2, :number_format => '%', :color => '#372a24')
		core.core_indicator_translations.create(:locale => 'en', :name => 'Labour Council of Georgia',
			:name_abbrv => 'Labour Council',
			:description => 'Vote share Labour Council of Georgia (%)')
		core.core_indicator_translations.create(:locale => 'ka', :name => 'საქართველოს მშრომელთა საბჭო',
			:name_abbrv => 'მშრომელთა საბჭო',
			:description => 'ხმების გადანაწილება, საქართველოს მშრომელთა საბჭო (%)')

		# Georgian Dream
		core = CoreIndicator.create(:indicator_type_id => 2, :number_format => '%', :color => '#C83639')
		core.core_indicator_translations.create(:locale => 'en', :name => 'Georgian Dream',
			:name_abbrv => 'Georgian Dream',
			:description => 'Vote share Georgian Dream (%)')
		core.core_indicator_translations.create(:locale => 'ka', :name => 'ქართული ოცნება',
			:name_abbrv => 'ქართული ოცნება',
			:description => 'ხმების გადანაწილება, ქართული ოცნება (%)')

  end

  def down
		names = ['Free Georgia', 'Public Movement', 'People\'s Party', 'Merab Kostava Society', 'Labour Council of Georgia', 'Georgian Dream']
		trans = CoreIndicatorTranslation.where("locale = 'en' and name in (?)", names)

		CoreIndicator.where("id in (?)", trans.collect(&:core_indicator_id)).destroy_all

  end
end
