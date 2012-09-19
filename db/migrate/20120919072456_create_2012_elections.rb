# encoding: utf-8
class Create2012Elections < ActiveRecord::Migration
  def up
		# 2012 parl party list
		e = Event.create(:event_date => '2012-10-01', :event_type_id => 3, :shape_id => 65134)
		e.event_translations.create(:locale=>"en", :name=>"2012 Parliamentary - Party List", :name_abbrv => '2012 Party List', :description => 'The results of the October 1, 2012 election for party list representation (proportional) in Parliament. Members of Parliament are elected for four year terms.')
		e.event_translations.create(:locale=>"ka", :name=>"2012 წლის საპარლამენტო არჩევნები - პარტიული სია
", :name_abbrv => '2012 პარტიული სია', :description => '2008 წლის 21 მაისის საპარლამენტო არჩევნების შედეგები პარტიული სიით (პროპორციული წესით). პარლამენტის წევრები აირჩევიან ოთხი წლის ვადით.')
		# create live event menu record
		MenuLiveEvent.create(:event_id => e.id, :menu_start_date => '2012-09-17', :menu_end_date => '2012-10-08')

		# 2012 parl major
		e = Event.create(:event_date => '2012-10-01', :event_type_id => 3, :shape_id => 65134)
		e.event_translations.create(:locale=>"en", :name=>"2012 Parliamentary - Majoritarian", :name_abbrv => '2012 Majoritarian', :description => 'The results of the October 1, 2012 election for majoritarian districts of Parliament. Members of Parliament are elected for four year terms.')
		e.event_translations.create(:locale=>"ka", :name=>"2012 წლის საპარლამენტო არჩევნები - მაჟორიტარული", :name_abbrv => '2012 მაჟორიტარული', :description => '2008 წლის 21 მაისის საპარლამენტო არჩევნების შედეგები მაჟორიტარული წესით. პარლამენტის წევრები აირჩევიან ოთხი წლის ვადით.')
		# create live event menu record
		MenuLiveEvent.create(:event_id => e.id, :menu_start_date => '2012-09-17', :menu_end_date => '2012-10-08')

		# 2012 adjara party list
		e = Event.create(:event_date => '2012-10-01', :event_type_id => 4, :shape_id => 65135)
		e.event_translations.create(:locale=>"en", :name=>"2012 Adjara Supreme Council - Party List", :name_abbrv => '2012 Party List', :description => 'The results of the November 3, 2008 election for party list representation (proportional) in the Adjara Supreme Council. Members of the Adjara Supreme Council are elected for four year terms.')
		e.event_translations.create(:locale=>"ka", :name=>"2012 წლის აჭარის უმაღლესი საბჭოს არჩევნები - პარტიული სია
", :name_abbrv => '2012 პარტიული სია', :description => '2008 წლის 3 ნოემბრის აჭარის უმაღლესი საბჭოს არჩევნების შედეგები პარტიული სიით (პროპორციული წესით). აჭარის უმაღლესი საბჭოს წევრები აირჩევიან ოთხი წლის ვადით.')
		# create live event menu record
		MenuLiveEvent.create(:event_id => e.id, :menu_start_date => '2012-09-17', :menu_end_date => '2012-10-08')

		# 2012 adjara major
		e = Event.create(:event_date => '2012-10-01', :event_type_id => 4, :shape_id => 65135	)
		e.event_translations.create(:locale=>"en", :name=>"2012 Adjara Supreme Council - Majoritarian", :name_abbrv => '2012 Majoritarian', :description => 'The results of the November 3, 2008 election for majoritarian districts of  the Adjara Supreme Council. Members of the Adjara Supreme Council are elected for four year terms.')
		e.event_translations.create(:locale=>"ka", :name=>"2012 წლის აჭარის უმაღლესი საბჭოს არჩევნები - მაჟორიტარული", :name_abbrv => '2012 მაჟორიტარული', :description => '2008 წლის 3 ნოემბრის აჭარის უმაღლესი საბჭოს არჩევნების შედეგები მაჟორიტარული წესით. აჭარის უმაღლესი საბჭოს წევრები აირჩევიან ოთხი წლის ვადით.')
		# create live event menu record
		MenuLiveEvent.create(:event_id => e.id, :menu_start_date => '2012-09-17', :menu_end_date => '2012-10-08')

    I18n.available_locales.each do |locale|
      Rails.cache.delete("live_event_menu_json_#{locale}")
    end

  end

  def down
		Event.where(:event_date => '2012-10-01').destroy_all

    I18n.available_locales.each do |locale|
      Rails.cache.delete("live_event_menu_json_#{locale}")
    end
  end
end
