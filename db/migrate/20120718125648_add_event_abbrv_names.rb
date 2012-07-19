# encoding: utf-8

class AddEventAbbrvNames < ActiveRecord::Migration
  def up

		# add column for short event name
		add_column :event_translations, :name_abbrv, :string
		add_index :event_translations, :name_abbrv

		# reassign the events to the types
		events = Event.where(:event_type_id => 1)
		# parl = 3,12,17,18
		ev = events.select{|x| [3,12,17,18].include?(x.id)}
		ev.each do |e|
			e.event_type_id = 3
			e.save
		end
		# adjara = 13,14,19,20
		ev = events.select{|x| [13,14,19,20].include?(x.id)}
		ev.each do |e|
			e.event_type_id = 4
			e.save
		end
		# local = 11,15,16
		ev = events.select{|x| [11,15,16].include?(x.id)}
		ev.each do |e|
			e.event_type_id = 5
			e.save
		end


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
		event_translations = nil
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
		ets = EventTypeTranslation.where(:event_type_id => 1)
		ets.each do |et|
			if et.locale == 'en'
				et.name = 'Elections'
			elsif et.locale == 'ka'
				et.name = 'არჩევნები'
			end
			et.save
		end
		events = Event.where("event_type_id != 2")
		events.each do |e|
			e.event_type_id = 1
			e.save
		end

		remove_index :event_translations, :name_abbrv
		remove_column :event_translations, :name_abbrv
  end
end
