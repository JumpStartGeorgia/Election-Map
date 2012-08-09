# encoding: utf-8
class AddEventDescText < ActiveRecord::Migration
  def up
		# en first
		event_translations = EventTranslation.where(:locale => 'en')
		#pres
    et = event_translations.select{|x| x.event_id == 2 }.first
    et.description = 'The results of the January 5, 2008 Presidential election. The President of Georgia is elected for a five year term. This election was a snap election.'
		et.save

		#parl
    et = event_translations.select{|x| x.event_id == 3 }.first
    et.description = 'The results of the May 21, 2008 election for party list representation (proportional) in Parliament. Members of Parliament are elected for four year terms. This election was a snap election held following the January 5, 2008 Presidential election.'
		et.save
    et = event_translations.select{|x| x.event_id == 12 }.first
    et.description = 'The results of the May  21, 2008 election for majoritarian districts of Parliament. Members of Parliament are elected for four year terms. This election was a snap election held following the January 5, 2008 Presidential election.'
		et.save
    et = event_translations.select{|x| x.event_id == 17 }.first
    et.description = 'The results of the October 2, 2010 election in Telavi district 17 for a vacant majoritarian seat in Parliament. The seat became vacant following the death of MP Giorgi Arsenishvili.'
		et.save
		# need to fix the date for this event
		e = Event.find(17)
		e.event_date = '2010-10-03'
		e.save

    et = event_translations.select{|x| x.event_id == 18 }.first
    et.description = 'The results of the November 3, 2008 elections in Vake District 2 and Didube District 8 for vacant majoritarian seats in Parliament. The seats became vacant following the annulment of their mandates by the United Opposition.'
		et.save


		#adjara
    et = event_translations.select{|x| x.event_id == 13 }.first
    et.description = 'The results of the November 3, 2008 election for party list representation (proportional) in the Adjara Supreme Council. Members of the Adjara Supreme Council are elected for four year terms.'
		et.save
    et = event_translations.select{|x| x.event_id == 14 }.first
    et.description = 'The results of the November 3, 2008 election for majoritarian districts of  the Adjara Supreme Council. Members of the Adjara Supreme Council are elected for four year terms.'
		et.save
    et = event_translations.select{|x| x.event_id == 19 }.first
    et.description = 'The results of the December 14, 2008 rerun of the Khelvuchauri district for the Adjara Supreme Council. The district became vacant following the annulment of election results by the Supreme Election Commission of Adjara.'
		et.save
    et = event_translations.select{|x| x.event_id == 20 }.first
    et.description = 'The results of the December 14, 2008 rerun of the Khelvuchauri district for the Adjara Supreme Council. The district became vacant following the annulment of election results by the Supreme Election Commission of Adjara.'
		et.save

		#local
    et = event_translations.select{|x| x.event_id == 11 }.first
    et.description = 'The results of the May 30, 2010 election for Mayor of Tbilisi. The Tbilisi Mayor is elected for four year terms. This was the first ever direct election for Mayor of Tbilisi.'
		et.save
    et = event_translations.select{|x| x.event_id == 15 }.first
    et.description = 'The results of the May 30, 2010 election for majoritarian districts of local city council (Sakrebulo). Local city councils are elected for four year terms.'
		et.save
    et = event_translations.select{|x| x.event_id == 16 }.first
    et.description = 'The results of the May 30, 2010 election for party list representation (proportional) in local city councils (Sakrebulo). Local city councils are elected for four year terms.'
		et.save

		#voter lists
    et = event_translations.select{|x| x.event_id == 1 }.first
    et.description = 'The Central Election Commission of Georgia (CEC) regularly updates the voter\'s list. These versions change over time to reflect population shifts and precinct re-division. According to the Election Code of Georgia, precincts may not contain more than 1,500 voters. All of the data was obtained by public information requests to the CEC since 2008. The CEC can be found at <a href="http://www.cec.gov.ge" target="_blank">http://www.cec.gov.ge</a>.'
		et.save
    et = event_translations.select{|x| x.event_id == 4 }.first
    et.description = 'The Central Election Commission of Georgia (CEC) regularly updates the voter\'s list. These versions change over time to reflect population shifts and precinct re-division. According to the Election Code of Georgia, precincts may not contain more than 1,500 voters. All of the data was obtained by public information requests to the CEC since 2008. The CEC can be found at <a href="http://www.cec.gov.ge" target="_blank">http://www.cec.gov.ge</a>.'
		et.save
    et = event_translations.select{|x| x.event_id == 5 }.first
    et.description = 'The Central Election Commission of Georgia (CEC) regularly updates the voter\'s list. These versions change over time to reflect population shifts and precinct re-division. According to the Election Code of Georgia, precincts may not contain more than 1,500 voters. All of the data was obtained by public information requests to the CEC since 2008. The CEC can be found at <a href="http://www.cec.gov.ge" target="_blank">http://www.cec.gov.ge</a>.'
		et.save
    et = event_translations.select{|x| x.event_id == 6 }.first
    et.description = 'The Central Election Commission of Georgia (CEC) regularly updates the voter\'s list. These versions change over time to reflect population shifts and precinct re-division. According to the Election Code of Georgia, precincts may not contain more than 1,500 voters. All of the data was obtained by public information requests to the CEC since 2008. The CEC can be found at <a href="http://www.cec.gov.ge" target="_blank">http://www.cec.gov.ge</a>.'
		et.save
    et = event_translations.select{|x| x.event_id == 7 }.first
    et.description = 'The Central Election Commission of Georgia (CEC) regularly updates the voter\'s list. These versions change over time to reflect population shifts and precinct re-division. According to the Election Code of Georgia, precincts may not contain more than 1,500 voters. All of the data was obtained by public information requests to the CEC since 2008. The CEC can be found at <a href="http://www.cec.gov.ge" target="_blank">http://www.cec.gov.ge</a>.'
		et.save
    et = event_translations.select{|x| x.event_id == 8 }.first
    et.description = 'The Central Election Commission of Georgia (CEC) regularly updates the voter\'s list. These versions change over time to reflect population shifts and precinct re-division. According to the Election Code of Georgia, precincts may not contain more than 1,500 voters. All of the data was obtained by public information requests to the CEC since 2008. The CEC can be found at <a href="http://www.cec.gov.ge" target="_blank">http://www.cec.gov.ge</a>.'
		et.save
    et = event_translations.select{|x| x.event_id == 9 }.first
    et.description = 'The Central Election Commission of Georgia (CEC) regularly updates the voter\'s list. These versions change over time to reflect population shifts and precinct re-division. According to the Election Code of Georgia, precincts may not contain more than 1,500 voters. All of the data was obtained by public information requests to the CEC since 2008. The CEC can be found at <a href="http://www.cec.gov.ge" target="_blank">http://www.cec.gov.ge</a>.'
		et.save
    et = event_translations.select{|x| x.event_id == 10 }.first
    et.description = 'The Central Election Commission of Georgia (CEC) regularly updates the voter\'s list. These versions change over time to reflect population shifts and precinct re-division. According to the Election Code of Georgia, precincts may not contain more than 1,500 voters. All of the data was obtained by public information requests to the CEC since 2008. The CEC can be found at <a href="http://www.cec.gov.ge" target="_blank">http://www.cec.gov.ge</a>.'
		et.save
    et = event_translations.select{|x| x.event_id == 21 }.first
    et.description = 'The Central Election Commission of Georgia (CEC) regularly updates the voter\'s list. These versions change over time to reflect population shifts and precinct re-division. According to the Election Code of Georgia, precincts may not contain more than 1,500 voters. All of the data was obtained by public information requests to the CEC since 2008. The CEC can be found at <a href="http://www.cec.gov.ge" target="_blank">http://www.cec.gov.ge</a>.'
		et.save

    ###########################
		# ka
		event_translations = nil
		event_translations = EventTranslation.where(:locale => 'ka')

		#pres
    et = event_translations.select{|x| x.event_id == 2 }.first
    et.description = '2008 წლის 5 იანვრის საპრეზიდენტო არჩევნების შედეგები. საქართველოს პრეზიდენტი აირჩევა ხუთი წლის ვადით. არჩევნები იყო რიგგარეშე.'
		et.save

		#parl
    et = event_translations.select{|x| x.event_id == 3 }.first
    et.description = '2008 წლის 21 მაისის საპარლამენტო არჩევნების შედეგები პარტიული სიით (პროპორციული წესით). პარლამენტის წევრები აირჩევიან ოთხი წლის ვადით. არჩევნები იყო რიგგარეშე და ჩატარდა 2008 წლის 5 იანვრის საპრეზიდენტო არჩევნების შემდეგ.'
		et.save
    et = event_translations.select{|x| x.event_id == 12 }.first
    et.description = '2008 წლის 21 მაისის საპარლამენტო არჩევნების შედეგები მაჟორიტარული წესით. პარლამენტის წევრები აირჩევიან ოთხი წლის ვადით. არჩევნები იყო რიგგარეშე და ჩატარდა 2008 წლის 5 იანვრის საპრეზიდენტო არჩევნების შემდეგ.'
		et.save
    et = event_translations.select{|x| x.event_id == 17 }.first
    et.description = '2010 წლის 2 ოქტომბრის შუალედური არჩევნების შედეგები თელავის მე-17 ოლქში მაჟორიტარული წესით. შუალედური არჩევნები ჩატარდა პარლამენტის წევრი გიორგი არსენიშვილის გარდაცვალების გამო.'
		et.save
    et = event_translations.select{|x| x.event_id == 18 }.first
    et.description = '2008 წლის 3 ნოემბრის შუალედური არჩევნების შედეგები ვაკის მე-2 ოლქსა და დიდუბის მე-8 ოლქში მაჟორიტარული წესით. შუალედური არჩევნები ჩატარდა გაერთიანებული ოპოზიციის წარმომადგენლების მიერ მანდატებზე უარის თქმის გამო.'
		et.save


		#adjara
    et = event_translations.select{|x| x.event_id == 13 }.first
    et.description = '2008 წლის 3 ნოემბრის აჭარის უმაღლესი საბჭოს არჩევნების შედეგები პარტიული სიით (პროპორციული წესით). აჭარის უმაღლესი საბჭოს წევრები აირჩევიან ოთხი წლის ვადით.'
		et.save
    et = event_translations.select{|x| x.event_id == 14 }.first
    et.description = '2008 წლის 3 ნოემბრის აჭარის უმაღლესი საბჭოს არჩევნების შედეგები მაჟორიტარული წესით. აჭარის უმაღლესი საბჭოს წევრები აირჩევიან ოთხი წლის ვადით.'
		et.save
    et = event_translations.select{|x| x.event_id == 19 }.first
    et.description = '2008 წლის 14 დეკემბრის აჭარის უმაღლესი საბჭოს ხელვაჩაურის ოლქის ხელახალი არჩევნების შედეგები. ხელახალი არჩევნები ჩატარდა აჭარის უმაღლესი საარჩევნო კომისიის მიერ ოლქის შედეგების ბათილად გამოცხადების გამო.'
		et.save
    et = event_translations.select{|x| x.event_id == 20 }.first
    et.description = '2008 წლის 14 დეკემბრის აჭარის უმაღლესი საბჭოს ხელვაჩაურის ოლქის ხელახალი არჩევნების შედეგები. ხელახალი არჩევნები ჩატარდა აჭარის უმაღლესი საარჩევნო კომისიის მიერ ოლქის შედეგების ბათილად გამოცხადების გამო.'
		et.save


		#local
    et = event_translations.select{|x| x.event_id == 11 }.first
    et.description = '2010 წლის 30 მაისის თბილისის მერის არჩევნების შედეგები. თბილისის მერი არჩეულია ოთხი წლის ვადით. თბილისის მერი პირდაპირი არჩევნების წესით პირველად იქნა არჩეული.'
		et.save
    et = event_translations.select{|x| x.event_id == 15 }.first
    et.description = '2010 წლის 30 მაისის ადგილობრივი საკრებულოს მაჟორიტარული ოლქების შედეგები. საკრებულო არჩეულია ოთხი წლის ვადით.'
		et.save
    et = event_translations.select{|x| x.event_id == 16 }.first
    et.description = '2010 წლის 30 მაისის ადგილობრივი საკრებულოს არჩევნების შედეგები პარტიული სიით (პროპორციული წესით). საკრებულო არჩეულია ოთხი წლის ვადით.'
		et.save

		#voter lists
    et = event_translations.select{|x| x.event_id == 1 }.first
    et.description = 'ცენტრალური საარჩევნო კომისია (ცესკო) რეგულარულად ახდენს ამომრჩეველთა სიის განახლებას. ამომრჩეველთა სია იცვლება მოსახლეობის გადანაწილებისა და საარჩევნო უბნების საზღვრების ცვლილებების გამო. საქართველოს საარჩევნო კოდექსის თანახმად, ამომრჩეველთა რაოდენობა თითოეულ უბანზე არ აღემატება 1500. მონაცემები მოპოვებულია 2008 წლიდან ცესკოსგან საჯარო ინფორმაციის გამოთხოვის მეთოდით. ცესკოს ვებ-გვერდის მისამართია: <a href="http://www.cec.gov.ge" target="_blank">http://www.cec.gov.ge</a>.'
		et.save
    et = event_translations.select{|x| x.event_id == 4 }.first
    et.description = 'ცენტრალური საარჩევნო კომისია (ცესკო) რეგულარულად ახდენს ამომრჩეველთა სიის განახლებას. ამომრჩეველთა სია იცვლება მოსახლეობის გადანაწილებისა და საარჩევნო უბნების საზღვრების ცვლილებების გამო. საქართველოს საარჩევნო კოდექსის თანახმად, ამომრჩეველთა რაოდენობა თითოეულ უბანზე არ აღემატება 1500. მონაცემები მოპოვებულია 2008 წლიდან ცესკოსგან საჯარო ინფორმაციის გამოთხოვის მეთოდით. ცესკოს ვებ-გვერდის მისამართია: <a href="http://www.cec.gov.ge" target="_blank">http://www.cec.gov.ge</a>.'
		et.save
    et = event_translations.select{|x| x.event_id == 5 }.first
    et.description = 'ცენტრალური საარჩევნო კომისია (ცესკო) რეგულარულად ახდენს ამომრჩეველთა სიის განახლებას. ამომრჩეველთა სია იცვლება მოსახლეობის გადანაწილებისა და საარჩევნო უბნების საზღვრების ცვლილებების გამო. საქართველოს საარჩევნო კოდექსის თანახმად, ამომრჩეველთა რაოდენობა თითოეულ უბანზე არ აღემატება 1500. მონაცემები მოპოვებულია 2008 წლიდან ცესკოსგან საჯარო ინფორმაციის გამოთხოვის მეთოდით. ცესკოს ვებ-გვერდის მისამართია: <a href="http://www.cec.gov.ge" target="_blank">http://www.cec.gov.ge</a>.'
		et.save
    et = event_translations.select{|x| x.event_id == 6 }.first
    et.description = 'ცენტრალური საარჩევნო კომისია (ცესკო) რეგულარულად ახდენს ამომრჩეველთა სიის განახლებას. ამომრჩეველთა სია იცვლება მოსახლეობის გადანაწილებისა და საარჩევნო უბნების საზღვრების ცვლილებების გამო. საქართველოს საარჩევნო კოდექსის თანახმად, ამომრჩეველთა რაოდენობა თითოეულ უბანზე არ აღემატება 1500. მონაცემები მოპოვებულია 2008 წლიდან ცესკოსგან საჯარო ინფორმაციის გამოთხოვის მეთოდით. ცესკოს ვებ-გვერდის მისამართია: <a href="http://www.cec.gov.ge" target="_blank">http://www.cec.gov.ge</a>.'
		et.save
    et = event_translations.select{|x| x.event_id == 7 }.first
    et.description = 'ცენტრალური საარჩევნო კომისია (ცესკო) რეგულარულად ახდენს ამომრჩეველთა სიის განახლებას. ამომრჩეველთა სია იცვლება მოსახლეობის გადანაწილებისა და საარჩევნო უბნების საზღვრების ცვლილებების გამო. საქართველოს საარჩევნო კოდექსის თანახმად, ამომრჩეველთა რაოდენობა თითოეულ უბანზე არ აღემატება 1500. მონაცემები მოპოვებულია 2008 წლიდან ცესკოსგან საჯარო ინფორმაციის გამოთხოვის მეთოდით. ცესკოს ვებ-გვერდის მისამართია: <a href="http://www.cec.gov.ge" target="_blank">http://www.cec.gov.ge</a>.'
		et.save
    et = event_translations.select{|x| x.event_id == 8 }.first
    et.description = 'ცენტრალური საარჩევნო კომისია (ცესკო) რეგულარულად ახდენს ამომრჩეველთა სიის განახლებას. ამომრჩეველთა სია იცვლება მოსახლეობის გადანაწილებისა და საარჩევნო უბნების საზღვრების ცვლილებების გამო. საქართველოს საარჩევნო კოდექსის თანახმად, ამომრჩეველთა რაოდენობა თითოეულ უბანზე არ აღემატება 1500. მონაცემები მოპოვებულია 2008 წლიდან ცესკოსგან საჯარო ინფორმაციის გამოთხოვის მეთოდით. ცესკოს ვებ-გვერდის მისამართია: <a href="http://www.cec.gov.ge" target="_blank">http://www.cec.gov.ge</a>.'
		et.save
    et = event_translations.select{|x| x.event_id == 9 }.first
    et.description = 'ცენტრალური საარჩევნო კომისია (ცესკო) რეგულარულად ახდენს ამომრჩეველთა სიის განახლებას. ამომრჩეველთა სია იცვლება მოსახლეობის გადანაწილებისა და საარჩევნო უბნების საზღვრების ცვლილებების გამო. საქართველოს საარჩევნო კოდექსის თანახმად, ამომრჩეველთა რაოდენობა თითოეულ უბანზე არ აღემატება 1500. მონაცემები მოპოვებულია 2008 წლიდან ცესკოსგან საჯარო ინფორმაციის გამოთხოვის მეთოდით. ცესკოს ვებ-გვერდის მისამართია: <a href="http://www.cec.gov.ge" target="_blank">http://www.cec.gov.ge</a>.'
		et.save
    et = event_translations.select{|x| x.event_id == 10 }.first
    et.description = 'ცენტრალური საარჩევნო კომისია (ცესკო) რეგულარულად ახდენს ამომრჩეველთა სიის განახლებას. ამომრჩეველთა სია იცვლება მოსახლეობის გადანაწილებისა და საარჩევნო უბნების საზღვრების ცვლილებების გამო. საქართველოს საარჩევნო კოდექსის თანახმად, ამომრჩეველთა რაოდენობა თითოეულ უბანზე არ აღემატება 1500. მონაცემები მოპოვებულია 2008 წლიდან ცესკოსგან საჯარო ინფორმაციის გამოთხოვის მეთოდით. ცესკოს ვებ-გვერდის მისამართია: <a href="http://www.cec.gov.ge" target="_blank">http://www.cec.gov.ge</a>.'
		et.save
    et = event_translations.select{|x| x.event_id == 21 }.first
    et.description = 'ცენტრალური საარჩევნო კომისია (ცესკო) რეგულარულად ახდენს ამომრჩეველთა სიის განახლებას. ამომრჩეველთა სია იცვლება მოსახლეობის გადანაწილებისა და საარჩევნო უბნების საზღვრების ცვლილებების გამო. საქართველოს საარჩევნო კოდექსის თანახმად, ამომრჩეველთა რაოდენობა თითოეულ უბანზე არ აღემატება 1500. მონაცემები მოპოვებულია 2008 წლიდან ცესკოსგან საჯარო ინფორმაციის გამოთხოვის მეთოდით. ცესკოს ვებ-გვერდის მისამართია: <a href="http://www.cec.gov.ge" target="_blank">http://www.cec.gov.ge</a>.'
		et.save  end

  def down
		#do nothing
  end
end
