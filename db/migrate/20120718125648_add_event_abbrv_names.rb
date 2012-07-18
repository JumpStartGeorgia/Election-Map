# encoding: utf-8

class AddEventAbbrvNames < ActiveRecord::Migration
  def up

		# add column for short event name
		add_column :event_translations, :name_abbrv, :string
		add_index :event_translations, :name_abbrv

		# assign new short event names
		event_translations = EventTranslation.all

		#pres
		ets = event_translations.select{|x| [2].include?(x.event_id) }
		ets.each do |et|
			if et.locale = 'en'
				et.name_abbrv = et.name.gsub(" Presidential", "")
			elsif et.locale = 'ka'
				et.name_abbrv = et.name.gsub(" საპრეზიდენტო", "")
			end
			et.save
		end

		#parl
		ets = event_translations.select{|x| [3,12,17,18].include?(x.event_id) }
		ets.each do |et|
			if et.locale = 'en'
				et.name_abbrv = et.name.gsub("Parliamentary ", "")
			elsif et.locale = 'ka'
				et.name_abbrv = et.name.gsub("საპარლამენტო ", "")
			end
			et.save
		end

		#adjara - leave as is
		ets = event_translations.select{|x| [13,14,19,20].include?(x.event_id) }
		ets.each do |et|
			et.name_abbrv = et.name
			et.save
		end

		#local
		ets = event_translations.select{|x| [11,15,16].include?(x.event_id) }
		ets.each do |et|
			if et.locale = 'en'
				et.name_abbrv = et.name.gsub("Local Election ", "").gsub(" Election", "")
			elsif et.locale = 'ka'
				et.name_abbrv = et.name.gsub("ადგილობრივი თვითმმართველობის არჩევნები,", "-").gsub(" არჩევნები", "")
			end
			et.save
		end

		#voter lists
		ets = event_translations.select{|x| [1,4,5,6,7,8,9,10,21].include?(x.event_id) }
		ets.each do |et|
			if et.locale = 'en'
				et.name_abbrv = et.name.gsub("Release ", "")
			elsif et.locale = 'ka'
				et.name_abbrv = et.name.gsub(" მდგომარეობით", "")
			end
			et.save
		end

  end

  def down
		remove_index :event_translations, :name_abbrv
		remove_column :event_translations, :name_abbrv
  end
end
