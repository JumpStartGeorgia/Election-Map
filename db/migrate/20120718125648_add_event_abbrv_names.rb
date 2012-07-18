# encoding: utf-8

class AddEventAbbrvNames < ActiveRecord::Migration
  def up
=begin
		# add column for short event name
		add_column :event_translations, :name_abbrv, :string
		add_index :event_translations, :name_abbrv
=end
		# assign new short event names
		# en first
		event_translations = EventTranslation.where(:locale => 'en')

    et = event_translations.select{|x| x.event_id == 2 }.first
    et.name_abbrv = '2008'
		et.save

		#parl
    et = event_translations.select{|x| x.event_id == 3 }.first
    et.name_abbrv = '2008 Party List'
		et.save
    et = event_translations.select{|x| x.event_id == 12 }.first
    et.name_abbrv = '2008 Majoritarian'
		et.save
    et = event_translations.select{|x| x.event_id == 17 }.first
    et.name_abbrv = '2010 Bi-election Majoritarian'
		et.save
    et = event_translations.select{|x| x.event_id == 18 }.first
    et.name_abbrv = '2008 Bi-election Majoritarian'
		et.save


		#adjara - leave as is
		ets = event_translations.select{|x| [13,14,19,20].include?(x.event_id) }
		ets.each do |et|
			et.name_abbrv = et.name
			et.save
		end

		#local
    et = event_translations.select{|x| x.event_id == 11 }.first
    et.name_abbrv = '2010 Tbilisi Mayor'
		et.save
    et = event_translations.select{|x| x.event_id == 15 }.first
    et.name_abbrv = '2010 Majoritarian'
		et.save
    et = event_translations.select{|x| x.event_id == 16 }.first
    et.name_abbrv = '2010 Party List'
		et.save

		#voter lists
    et = event_translations.select{|x| x.event_id == 1 }.first
    et.name_abbrv = '2007'
		et.save
    et = event_translations.select{|x| x.event_id == 4 }.first
    et.name_abbrv = '2006'
		et.save
    et = event_translations.select{|x| x.event_id == 5 }.first
    et.name_abbrv = '2008 January'
		et.save
    et = event_translations.select{|x| x.event_id == 6 }.first
    et.name_abbrv = '2008 April'
		et.save
    et = event_translations.select{|x| x.event_id == 7 }.first
    et.name_abbrv = '2008 May'
		et.save
    et = event_translations.select{|x| x.event_id == 8 }.first
    et.name_abbrv = '2009'
		et.save
    et = event_translations.select{|x| x.event_id == 9 }.first
    et.name_abbrv = '2010 February'
		et.save
    et = event_translations.select{|x| x.event_id == 10 }.first
    et.name_abbrv = '2010 May'
		et.save
    et = event_translations.select{|x| x.event_id == 21 }.first
    et.name_abbrv = '2011 May'
		et.save
    
    ###########################
		# ka
		event_translations = EventTranslation.where(:locale => 'ka')

		#pres
    et = event_translations.select{|x| x.event_id == 2 }.first
    et.name_abbrv = '2008'
		et.save

		#parl
    et = event_translations.select{|x| x.event_id == 3 }.first
    et.name_abbrv = '2008 პარტიულ სიაში'
		et.save
    et = event_translations.select{|x| x.event_id == 12 }.first
    et.name_abbrv = '2008 მაჟორიტარული'
		et.save
    et = event_translations.select{|x| x.event_id == 17 }.first
    et.name_abbrv = '2010 შუალედური მაჟორიტარული'
		et.save
    et = event_translations.select{|x| x.event_id == 18 }.first
    et.name_abbrv = '2008 შუალედური მაჟორიტარული'
		et.save


		#adjara - leave as is
		ets = event_translations.select{|x| [13,14,19,20].include?(x.event_id) }
		ets.each do |et|
			et.name_abbrv = et.name
			et.save
		end

		#local
    et = event_translations.select{|x| x.event_id == 11 }.first
    et.name_abbrv = '2010 თბილისის მერის'
		et.save
    et = event_translations.select{|x| x.event_id == 15 }.first
    et.name_abbrv = '2010 მაჟორიტარული'
		et.save
    et = event_translations.select{|x| x.event_id == 16 }.first
    et.name_abbrv = '2010 პარტიული სია'
		et.save

		#voter lists
    et = event_translations.select{|x| x.event_id == 1 }.first
    et.name_abbrv = '2007'
		et.save
    et = event_translations.select{|x| x.event_id == 4 }.first
    et.name_abbrv = '2006'
		et.save
    et = event_translations.select{|x| x.event_id == 5 }.first
    et.name_abbrv = '2008 იანვრის'
		et.save
    et = event_translations.select{|x| x.event_id == 6 }.first
    et.name_abbrv = '2008 აპრილის'
		et.save
    et = event_translations.select{|x| x.event_id == 7 }.first
    et.name_abbrv = '2008 მაისის'
		et.save
    et = event_translations.select{|x| x.event_id == 8 }.first
    et.name_abbrv = '2009'
		et.save
    et = event_translations.select{|x| x.event_id == 9 }.first
    et.name_abbrv = '2010 თებერვლის'
		et.save
    et = event_translations.select{|x| x.event_id == 10 }.first
    et.name_abbrv = '2010 მაისის'
		et.save
    et = event_translations.select{|x| x.event_id == 21 }.first
    et.name_abbrv = '2011 მაისის'
		et.save

  end

  def down
		remove_index :event_translations, :name_abbrv
		remove_column :event_translations, :name_abbrv
  end
end
