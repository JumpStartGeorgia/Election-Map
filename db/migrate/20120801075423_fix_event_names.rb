# encoding: utf-8
class FixEventNames < ActiveRecord::Migration
  def up
		# en first
		event_translations = EventTranslation.where(:locale => 'en')
		#pres
    et = event_translations.select{|x| x.event_id == 2 }.first
    et.name = '2008 Presidential'
		et.save

		#parl
    et = event_translations.select{|x| x.event_id == 3 }.first
    et.name = '2008 Parliamentary - Party List'
		et.save
    et = event_translations.select{|x| x.event_id == 12 }.first
    et.name = '2008 Parliamentary - Majoritarian'
		et.save
    et = event_translations.select{|x| x.event_id == 17 }.first
    et.name = '2010 Parliamentary Bi-election - Majoritarian'
		et.save
    et = event_translations.select{|x| x.event_id == 18 }.first
    et.name = '2008 Parliamentary Bi-election - Majoritarian'
		et.save


		#adjara
    et = event_translations.select{|x| x.event_id == 13 }.first
    et.name = '2008 Adjara Supreme Council - Party List'
		et.save
    et = event_translations.select{|x| x.event_id == 14 }.first
    et.name = '2008 Adjara Supreme Council - Majoritarian'
		et.save
    et = event_translations.select{|x| x.event_id == 19 }.first
    et.name = '2008 Adjara Supreme Council - Party List Re-run'
		et.save
    et = event_translations.select{|x| x.event_id == 20 }.first
    et.name = '2008 Adjara Supreme Council - Majoritarian Re-run'
		et.save

		#local
    et = event_translations.select{|x| x.event_id == 11 }.first
    et.name = '2010 Tbilisi Mayor Election'
		et.save
    et = event_translations.select{|x| x.event_id == 15 }.first
    et.name = '2010 Local Election - Majoritarian'
		et.save
    et = event_translations.select{|x| x.event_id == 16 }.first
    et.name = '2010 Local Election - Party List'
		et.save

		#voter lists
    et = event_translations.select{|x| x.event_id == 1 }.first
    et.name = '2007 Voters List'
		et.save
    et = event_translations.select{|x| x.event_id == 4 }.first
    et.name = '2006 Voters List'
		et.save
    et = event_translations.select{|x| x.event_id == 5 }.first
    et.name = '2008 January Voters List'
		et.save
    et = event_translations.select{|x| x.event_id == 6 }.first
    et.name = '2008 April Voters List'
		et.save
    et = event_translations.select{|x| x.event_id == 7 }.first
    et.name = '2008 May Voters List'
		et.save
    et = event_translations.select{|x| x.event_id == 8 }.first
    et.name = '2009 Voters List'
		et.save
    et = event_translations.select{|x| x.event_id == 9 }.first
    et.name = '2010 February Voters List'
		et.save
    et = event_translations.select{|x| x.event_id == 10 }.first
    et.name = '2010 May Voters List'
		et.save
    et = event_translations.select{|x| x.event_id == 21 }.first
    et.name = '2011 May Voters List'
		et.save

    ###########################
		# ka
		event_translations = nil
		event_translations = EventTranslation.where(:locale => 'ka')

		#pres
    et = event_translations.select{|x| x.event_id == 2 }.first
    et.name = '2008 წლის საპრეზიდენტო არჩევნები'
		et.save

		#parl
    et = event_translations.select{|x| x.event_id == 3 }.first
    et.name = '2008 წლის საპარლამენტო არჩევნები - პარტიული სია'
		et.save
    et = event_translations.select{|x| x.event_id == 12 }.first
    et.name = '2008 წლის საპარლამენტო არჩევნები - მაჟორიტარული'
		et.save
    et = event_translations.select{|x| x.event_id == 17 }.first
    et.name = '2010 წლის შუალედური საპარლამენტო არჩევნები - მაჟორიტარული'
		et.save
    et = event_translations.select{|x| x.event_id == 18 }.first
    et.name = '2008 წლის შუალედური საპარლამენტო არჩევნები - მაჟორიტარული'
		et.save


		#adjara
    et = event_translations.select{|x| x.event_id == 13 }.first
    et.name = '2008 წლის აჭარის უმაღლესი საბჭოს არჩევნები - პარტიული სია'
		et.save
    et = event_translations.select{|x| x.event_id == 14 }.first
    et.name = '2008 წლის აჭარის უმაღლესი საბჭოს არჩევნები - მაჟორიტარული'
		et.save
    et = event_translations.select{|x| x.event_id == 19 }.first
    et.name = '2008 წლის აჭარის უმაღლესი საბჭოს ხელახალი არჩევნები - პარტიული სია'
		et.save
    et = event_translations.select{|x| x.event_id == 20 }.first
    et.name = '2008 წლის აჭარის უმაღლესი საბჭოს ხელახალი არჩევნები - მაჟორიტარული'
		et.save


		#local
    et = event_translations.select{|x| x.event_id == 11 }.first
    et.name = '2010 წლის თბილისის მერის არჩევნები'
		et.save
    et = event_translations.select{|x| x.event_id == 15 }.first
    et.name = '2010 წლის ადგილობრივი თვითმმართველობის არჩევნები - მაჟორიტარული'
		et.save
    et = event_translations.select{|x| x.event_id == 16 }.first
    et.name = '2010 წლის ადგილობრივი თვითმმართველობის არჩევნები - პარტიული სია'
		et.save

		#voter lists
    et = event_translations.select{|x| x.event_id == 1 }.first
    et.name = '2007 წლის ამომრჩეველთა სია'
		et.save
    et = event_translations.select{|x| x.event_id == 4 }.first
    et.name = '2006 წლის ამომრჩეველთა სია'
		et.save
    et = event_translations.select{|x| x.event_id == 5 }.first
    et.name = '2008 წლის იანვრის ამომრჩეველთა სია'
		et.save
    et = event_translations.select{|x| x.event_id == 6 }.first
    et.name = '2008 წლის აპრილის ამომრჩეველთა სია'
		et.save
    et = event_translations.select{|x| x.event_id == 7 }.first
    et.name = '2008 წლის მაისის ამომრჩეველთა სია'
		et.save
    et = event_translations.select{|x| x.event_id == 8 }.first
    et.name = '2009 წლის ამომრჩეველთა სია'
		et.save
    et = event_translations.select{|x| x.event_id == 9 }.first
    et.name = '2010 წლის თებერვლის ამომრჩეველთა სია'
		et.save
    et = event_translations.select{|x| x.event_id == 10 }.first
    et.name = '2010 წლის მაისის ამომრჩეველთა სია'
		et.save
    et = event_translations.select{|x| x.event_id == 21 }.first
    et.name = '2011 წლის მაისის ამომრჩეველთა სია'
		et.save
  end

  def down
		# do nothing
  end
end
