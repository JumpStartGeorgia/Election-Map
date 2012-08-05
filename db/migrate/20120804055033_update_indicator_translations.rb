# encoding: utf-8

class UpdateIndicatorTranslations < ActiveRecord::Migration
  def up

    cits = CoreIndicatorTranslation.where(:core_indicator_id => 34)
		cit = cits.select{|x| x.locale == 'en'}.first
    cit.name_abbrv = 'Alasania'
    cit.description = 'Vote share Irakli Alasania (%)'
		cit.save
		cit = cits.select{|x| x.locale == 'ka'}.first
    cit.name_abbrv = 'ალასანია'
    cit.description = 'ხმების გადანაწილება, ირაკლი ალასანია (%)'
		cit.save

    cits = CoreIndicatorTranslation.where(:core_indicator_id => 18)
		cit = cits.select{|x| x.locale == 'en'}.first
    cit.name_abbrv = 'Alliance'
    cit.description = 'Vote share Alliance for Georgia (%)'
		cit.save
		cit = cits.select{|x| x.locale == 'ka'}.first
    cit.name_abbrv = 'ალიანსი'
    cit.description = 'ხმების გადანაწილება, ალიანსი საქართველოსთვის (%)'
		cit.save

    cits = CoreIndicatorTranslation.where(:core_indicator_id => 21)
		cit = cits.select{|x| x.locale == 'en'}.first
    cit.name_abbrv = 'CDA'
    cit.description = 'Vote share Christian Democratic Alliance (%)'
		cit.save
		cit = cits.select{|x| x.locale == 'ka'}.first
    cit.name_abbrv = 'ქრისტიან-დემოკრატიული ალიანსი'
    cit.description = 'ხმების გადანაწილება, ქრისტიან-დემოკრატიული ალიანსი (%)'
		cit.save

    cits = CoreIndicatorTranslation.where(:core_indicator_id => 20)
		cit = cits.select{|x| x.locale == 'en'}.first
    cit.name_abbrv = 'CDM'
    cit.description = 'Vote share Christian-Democratic Movement (%)'
		cit.save
		cit = cits.select{|x| x.locale == 'ka'}.first
    cit.name_abbrv = 'ქდმ'
    cit.description = 'ხმების გადანაწილება, ქრისტიანულ-დემოკრატიული მოძრაობა (%)'
		cit.save

    cits = CoreIndicatorTranslation.where(:core_indicator_id => 30)
		cit = cits.select{|x| x.locale == 'en'}.first
    cit.name_abbrv = 'Chanturia'
    cit.description = 'Vote share Giorgi Chanturia (%)'
		cit.save
		cit = cits.select{|x| x.locale == 'ka'}.first
    cit.name_abbrv = 'ჭანტურია'
    cit.description = 'ხმების გადანაწილება, გია ჭანტურია (%)'
		cit.save

    cits = CoreIndicatorTranslation.where(:core_indicator_id => 63)
		cit = cits.select{|x| x.locale == 'en'}.first
    cit.name_abbrv = 'Dzidziguri'
    cit.description = 'Vote share Zviad Dzidziguri (%)'
		cit.save
		cit = cits.select{|x| x.locale == 'ka'}.first
    cit.name_abbrv = 'ძიძიგური'
    cit.description = 'ხმების გადანაწილება, ზვიად ძიძიგური (%)'
		cit.save

    cits = CoreIndicatorTranslation.where(:core_indicator_id => 25)
		cit = cits.select{|x| x.locale == 'en'}.first
    cit.name_abbrv = 'Future Geo.'
    cit.description = 'Vote share Future Georgia (%)'
		cit.save
		cit = cits.select{|x| x.locale == 'ka'}.first
    cit.name_abbrv = 'მომავალი საქართველო'
    cit.description = 'ხმების გადანაწილება, მომავალი საქართველო (%)'
		cit.save

    cits = CoreIndicatorTranslation.where(:core_indicator_id => 24)
		cit = cits.select{|x| x.locale == 'en'}.first
    cit.name_abbrv = 'Freedom'
    cit.description = 'Vote share Freedom Party (%)'
		cit.save
		cit = cits.select{|x| x.locale == 'ka'}.first
    cit.name_abbrv = 'თავისუფლება'
    cit.description = 'ხმების გადანაწილება, თავისუფლება (%)'
		cit.save

    cits = CoreIndicatorTranslation.where(:core_indicator_id => 37)
		cit = cits.select{|x| x.locale == 'en'}.first
    cit.name_abbrv = 'Gachechiladze'
    cit.description = 'Vote share Levan Gachechiladze (%)'
		cit.save
		cit = cits.select{|x| x.locale == 'ka'}.first
    cit.name_abbrv = 'გაჩეჩილაძე'
    cit.description = 'ხმების გადანაწილება, ლევან გაჩეჩილაძე (%)'
		cit.save

    cits = CoreIndicatorTranslation.where(:core_indicator_id => 22)
		cit = cits.select{|x| x.locale == 'en'}.first
    cit.name_abbrv = 'Gamkrelidze'
    cit.description = 'Vote share Davit Gamkrelidze (%)'
		cit.save
		cit = cits.select{|x| x.locale == 'ka'}.first
    cit.name_abbrv = 'გამყრელიძე'
    cit.description = 'ხმების გადანაწილება, დავით გამყრელიძე (%)'
		cit.save

    cits = CoreIndicatorTranslation.where(:core_indicator_id => 26)
		cit = cits.select{|x| x.locale == 'en'}.first
    cit.name_abbrv = 'Geo. Group'
    cit.description = 'Vote share Georgian Group (%)'
		cit.save
		cit = cits.select{|x| x.locale == 'ka'}.first
    cit.name_abbrv = 'ქართული დასი'
    cit.description = 'ხმების გადანაწილება, ქართული დასი (%)'
		cit.save

    cits = CoreIndicatorTranslation.where(:core_indicator_id => 27)
		cit = cits.select{|x| x.locale == 'en'}.first
    cit.name_abbrv = 'Geo. Politics'
    cit.description = 'Vote share Georgian Politics (%)'
		cit.save
		cit = cits.select{|x| x.locale == 'ka'}.first
    cit.name_abbrv = 'ქართული პოლიტიკა'
    cit.description = 'ხმების გადანაწილება, ქართული პოლიტიკა (%)'
		cit.save

    cits = CoreIndicatorTranslation.where(:core_indicator_id => 23)
		cit = cits.select{|x| x.locale == 'en'}.first
    cit.name_abbrv = 'Iakobidze'
    cit.description = 'Vote share Davit Iakobidze (%)'
		cit.save
		cit = cits.select{|x| x.locale == 'ka'}.first
    cit.name_abbrv = 'იაკობიძე'
    cit.description = 'ხმების გადანაწილება, დავით იაკობიძე (%)'
		cit.save

    cits = CoreIndicatorTranslation.where(:core_indicator_id => 33)
		cit = cits.select{|x| x.locale == 'en'}.first
    cit.name_abbrv = 'Industry'
    cit.description = 'Vote share Industry Will Save Georgia (%)'
		cit.save
		cit = cits.select{|x| x.locale == 'ka'}.first
    cit.name_abbrv = 'მრეწველები'
    cit.description = 'ხმების გადანაწილება, მრეწველობა გადაარჩენს საქართველოს (%)'
		cit.save

    cits = CoreIndicatorTranslation.where(:core_indicator_id => 36)
		cit = cits.select{|x| x.locale == 'en'}.first
    cit.name_abbrv = 'Labour'
    cit.description = 'Vote share Labour (%)'
		cit.save
		cit = cits.select{|x| x.locale == 'ka'}.first
    cit.name_abbrv = 'ლეიბორისტები'
    cit.description = 'ხმების გადანაწილება, ლეიბორისტული პარტია (%)'
		cit.save

    cits = CoreIndicatorTranslation.where(:core_indicator_id => 31)
		cit = cits.select{|x| x.locale == 'en'}.first
    cit.name_abbrv = 'Laghidze'
    cit.description = 'Vote share Giorgi Laghidze (%)'
		cit.save
		cit = cits.select{|x| x.locale == 'ka'}.first
    cit.name_abbrv = 'ლაღიძე'
    cit.description = 'ხმების გადანაწილება, გიორგი ლაღიძე (%)'
		cit.save

    cits = CoreIndicatorTranslation.where(:core_indicator_id => 29)
		cit = cits.select{|x| x.locale == 'en'}.first
    cit.name_abbrv = 'Maisashvili'
    cit.description = 'Vote share Giorgi (Gia) Maisashvili (%)'
		cit.save
		cit = cits.select{|x| x.locale == 'ka'}.first
    cit.name_abbrv = 'მაისაშვილი'
    cit.description = 'ხმების გადანაწილება, გიორგი (გია) მაისაშვილი (%)'
		cit.save

    cits = CoreIndicatorTranslation.where(:core_indicator_id => 38)
		cit = cits.select{|x| x.locale == 'en'}.first
    cit.name_abbrv = 'Mamulishvili'
    cit.description = 'Vote share Mamulishvili (%)'
		cit.save
		cit = cits.select{|x| x.locale == 'ka'}.first
    cit.name_abbrv = 'მამულიშვილი'
    cit.description = 'ხმების გადანაწილება, მამულიშვილი (%)'
		cit.save

    cits = CoreIndicatorTranslation.where(:core_indicator_id => 40)
		cit = cits.select{|x| x.locale == 'en'}.first
    cit.name_abbrv = 'For Fair Georgia'
    cit.description = 'Vote share Movement for Fair Georgia (%)'
		cit.save
		cit = cits.select{|x| x.locale == 'ka'}.first
    cit.name_abbrv = 'სამართლიანი საქართველოსთვის'
    cit.description = 'ხმების გადანაწილება, მოძრაობა სამართლიანი საქართველოსთვის (%)'
		cit.save

    cits = CoreIndicatorTranslation.where(:core_indicator_id => 45)
		cit = cits.select{|x| x.locale == 'en'}.first
    cit.name_abbrv = 'N. Ivanishvili'
    cit.description = 'Vote share Nikoloz Ivanishvili (%)'
		cit.save
		cit = cits.select{|x| x.locale == 'ka'}.first
    cit.name_abbrv = 'ნ. ივანიშვილი'
    cit.description = 'ხმების გადანაწილება, ნიკოლოზ ივანიშვილი (%)'
		cit.save

    cits = CoreIndicatorTranslation.where(:core_indicator_id => 46)
		cit = cits.select{|x| x.locale == 'en'}.first
    cit.name_abbrv = 'Public Democrats'
    cit.description = 'Vote share Nikoloz Ivanishvili Public Democrats (%)'
		cit.save
		cit = cits.select{|x| x.locale == 'ka'}.first
    cit.name_abbrv = 'სახალხო დემოკრატები'
    cit.description = 'ხმების გადანაწილება, ნიკოლოზ ივანიშვილი სახალხო დემოკრატები (%)'
		cit.save

    cits = CoreIndicatorTranslation.where(:core_indicator_id => 52)
		cit = cits.select{|x| x.locale == 'en'}.first
    cit.name_abbrv = 'Natelashvili'
    cit.description = 'Vote share Shalva Natelashvili (%)'
		cit.save
		cit = cits.select{|x| x.locale == 'ka'}.first
    cit.name_abbrv = 'ნათელაშვილი'
    cit.description = 'ხმების გადანაწილება, შალვა ნათელაშვილი (%)'
		cit.save

    cits = CoreIndicatorTranslation.where(:core_indicator_id => 41)
		cit = cits.select{|x| x.locale == 'en'}.first
    cit.name_abbrv = 'Nat. Council'
    cit.description = 'Vote share National Council (%)'
		cit.save
		cit = cits.select{|x| x.locale == 'ka'}.first
    cit.name_abbrv = 'ეროვნული საბჭო'
    cit.description = 'ხმების გადანაწილება, ეროვნული საბჭო (%)'
		cit.save

    cits = CoreIndicatorTranslation.where(:core_indicator_id => 43)
		cit = cits.select{|x| x.locale == 'en'}.first
    cit.name_abbrv = 'NDP'
    cit.description = 'Vote share National Democratic Party of Georgia (%)'
		cit.save
		cit = cits.select{|x| x.locale == 'ka'}.first
    cit.name_abbrv = 'ედპ'
    cit.description = 'ხმების გადანაწილება, საქართველოს ეროვნულ დემოკრატიული პარტია (%)'
		cit.save

    cits = CoreIndicatorTranslation.where(:core_indicator_id => 64)
		cit = cits.select{|x| x.locale == 'en'}.first
    cit.name_abbrv = 'New Rights'
    cit.description = 'Vote share New Rights (%)'
		cit.save
		cit = cits.select{|x| x.locale == 'ka'}.first
    cit.name_abbrv = 'ახალი მემარჯვენეები'
    cit.description = 'ხმების გადანაწილება, ახალი მემარჯვენეები (%)'
		cit.save

    cits = CoreIndicatorTranslation.where(:core_indicator_id => 44)
		cit = cits.select{|x| x.locale == 'en'}.first
    cit.name_abbrv = 'NPRDG'
    cit.description = 'Vote share National Party of Radical Democrats of Georgia (%)'
		cit.save
		cit = cits.select{|x| x.locale == 'ka'}.first
    cit.name_abbrv = 'რადიკალ-დემოკრატები'
    cit.description = 'ხმების გადანაწილება, სრულიად საქართველოს რადიკალ დემოკრატთა ნაციონალური პარტია (%)'
		cit.save

    cits = CoreIndicatorTranslation.where(:core_indicator_id => 47)
		cit = cits.select{|x| x.locale == 'en'}.first
    cit.name_abbrv = 'Our Country'
    cit.description = 'Vote share Our Country (%)'
		cit.save
		cit = cits.select{|x| x.locale == 'ka'}.first
    cit.name_abbrv = 'ჩვენი ქვეყანა'
    cit.description = 'ხმების გადანაწილება, ჩვენი ქვეყანა (%)'
		cit.save

    cits = CoreIndicatorTranslation.where(:core_indicator_id => 19)
		cit = cits.select{|x| x.locale == 'en'}.first
    cit.name_abbrv = 'Patarkatsishvili'
    cit.description = 'Vote share Arkadi (Badri) Patarkatsishvili (%)'
		cit.save
		cit = cits.select{|x| x.locale == 'ka'}.first
    cit.name_abbrv = 'პატარკაციშვილი'
    cit.description = 'ხმების გადანაწილება, არკადი (ბადრი) პატარკაციშვილი (%)'
		cit.save

    cits = CoreIndicatorTranslation.where(:core_indicator_id => 49)
		cit = cits.select{|x| x.locale == 'en'}.first
    cit.name_abbrv = 'PAWG'
    cit.description = 'Vote share Public Alliance of Whole Georgia (%)'
		cit.save
		cit = cits.select{|x| x.locale == 'ka'}.first
    cit.name_abbrv = 'საზოგადოებრივი ალიანსი'
    cit.description = 'ხმების გადანაწილება, საზოგადოებრივი ალიანსი ერთიანი საქართველოსათვის (%)'
		cit.save

    cits = CoreIndicatorTranslation.where(:core_indicator_id => 48)
		cit = cits.select{|x| x.locale == 'en'}.first
    cit.name_abbrv = 'Party of Future'
    cit.description = 'Vote share Party of Future (%)'
		cit.save
		cit = cits.select{|x| x.locale == 'ka'}.first
    cit.name_abbrv = 'მომავლის პარტია'
    cit.description = 'ხმების გადანაწილება, მომავლის პარტია (%)'
		cit.save

    cits = CoreIndicatorTranslation.where(:core_indicator_id => 50)
		cit = cits.select{|x| x.locale == 'en'}.first
    cit.name_abbrv = 'Republicans'
    cit.description = 'Vote share Republican party (%)'
		cit.save
		cit = cits.select{|x| x.locale == 'ka'}.first
    cit.name_abbrv = 'რესპუბლიკური პარტია'
    cit.description = 'ხმების გადანაწილება, რესპუბლიკური პარტია (%)'
		cit.save

    cits = CoreIndicatorTranslation.where(:core_indicator_id => 39)
		cit = cits.select{|x| x.locale == 'en'}.first
    cit.name_abbrv = 'Saakashvili'
    cit.description = 'Vote share Mikheil Saakashvili (%)'
		cit.save
		cit = cits.select{|x| x.locale == 'ka'}.first
    cit.name_abbrv = 'სააკაშვილი'
    cit.description = 'ხმების გადანაწილება, მიხეილ სააკაშვილი (%)'
		cit.save

    cits = CoreIndicatorTranslation.where(:core_indicator_id => 35)
		cit = cits.select{|x| x.locale == 'en'}.first
    cit.name_abbrv = 'Sarishvili'
    cit.description = 'Vote share Irina Sarishvili-Chanturia (%)'
		cit.save
		cit = cits.select{|x| x.locale == 'ka'}.first
    cit.name_abbrv = 'სარიშვილი'
    cit.description = 'ხმების გადანაწილება, ირინა სარიშვილი-ჭანტურია (%)'
		cit.save

    cits = CoreIndicatorTranslation.where(:core_indicator_id => 53)
		cit = cits.select{|x| x.locale == 'en'}.first
    cit.name_abbrv = 'Solidarity'
    cit.description = 'Vote share Solidarity (%)'
		cit.save
		cit = cits.select{|x| x.locale == 'ka'}.first
    cit.name_abbrv = 'სოლიდარობა'
    cit.description = 'ხმების გადანაწილება, სოლიდარობა (%)'
		cit.save

    cits = CoreIndicatorTranslation.where(:core_indicator_id => 54)
		cit = cits.select{|x| x.locale == 'en'}.first
    cit.name_abbrv = 'Sportsman\'s Union'
    cit.description = 'Vote share Sportsman\'s Union (%)'
		cit.save
		cit = cits.select{|x| x.locale == 'ka'}.first
    cit.name_abbrv = 'სპორტსმენთა კავშირი'
    cit.description = 'ხმების გადანაწილება, სპორტსმენთა კავშირი (%)'
		cit.save

    cits = CoreIndicatorTranslation.where(:core_indicator_id => 51)
		cit = cits.select{|x| x.locale == 'en'}.first
    cit.name_abbrv = 'Right Wing, Industrials'
    cit.description = 'Vote share Right Wing Alliance Topadze Industrialists (%)'
		cit.save
		cit = cits.select{|x| x.locale == 'ka'}.first
    cit.name_abbrv = 'მემარჯვენე მრეწველები'
    cit.description = 'ხმების გადანაწილება, მემარჯვენე ალიანსი თოფაძე მრეწველები (%)'
		cit.save

    cits = CoreIndicatorTranslation.where(:core_indicator_id => 32)
		cit = cits.select{|x| x.locale == 'en'}.first
    cit.name_abbrv = 'Topadze'
    cit.description = 'Vote share Giorgi Topadze (%)'
		cit.save
		cit = cits.select{|x| x.locale == 'ka'}.first
    cit.name_abbrv = 'თოფაძე'
    cit.description = 'ხმების გადანაწილება, გოგი თოფაძე (%)'
		cit.save

    cits = CoreIndicatorTranslation.where(:core_indicator_id => 56)
		cit = cits.select{|x| x.locale == 'en'}.first
    cit.name_abbrv = 'Tortladze'
    cit.description = 'Vote share Tortladze Democratic Party (%)'
		cit.save
		cit = cits.select{|x| x.locale == 'ka'}.first
    cit.name_abbrv = 'თორთლაძე'
    cit.description = 'ხმების გადანაწილება, თორთლაძე დემოკრატიული პარტია (%)'
		cit.save

    cits = CoreIndicatorTranslation.where(:core_indicator_id => 57)
		cit = cits.select{|x| x.locale == 'en'}.first
    cit.name_abbrv = 'Traditionalists'
    cit.description = 'Vote share Traditionalists - Our Georgia and Women\'s Party (%)'
		cit.save
		cit = cits.select{|x| x.locale == 'ka'}.first
    cit.name_abbrv = 'ტრადიციონალისტები'
    cit.description = 'ხმების გადანაწილება, ტრადიციონალისტები ჩვენი საქართველო და ქალთა პარტია (%)'
		cit.save

    cits = CoreIndicatorTranslation.where(:core_indicator_id => 58)
		cit = cits.select{|x| x.locale == 'en'}.first
    cit.name_abbrv = 'Communists'
    cit.description = 'Vote share United Communist Party (%)'
		cit.save
		cit = cits.select{|x| x.locale == 'ka'}.first
    cit.name_abbrv = 'კომუნისტები'
    cit.description = 'ხმების გადანაწილება, ერთიანი კომუნისტური პარტია (%)'
		cit.save

    cits = CoreIndicatorTranslation.where(:core_indicator_id => 28)
		cit = cits.select{|x| x.locale == 'en'}.first
    cit.name_abbrv = 'Ugulava'
    cit.description = 'Vote share Gigi Ugulava (%)'
		cit.save
		cit = cits.select{|x| x.locale == 'ka'}.first
    cit.name_abbrv = 'უგულავა'
    cit.description = 'ხმების გადანაწილება, გიგი უგულავა (%)'
		cit.save

    cits = CoreIndicatorTranslation.where(:core_indicator_id => 59)
		cit = cits.select{|x| x.locale == 'en'}.first
    cit.name_abbrv = 'UNM'
    cit.description = 'Vote share United National Movement (%)'
		cit.save
		cit = cits.select{|x| x.locale == 'ka'}.first
    cit.name_abbrv = 'ნაც. მოძრაობა'
    cit.description = 'ხმების გადანაწილება, ნაც. მოძრაობა (%)'
		cit.save

    cits = CoreIndicatorTranslation.where(:core_indicator_id => 60)
		cit = cits.select{|x| x.locale == 'en'}.first
    cit.name_abbrv = 'UO'
    cit.description = 'Vote share United Opposition (%)'
		cit.save
		cit = cits.select{|x| x.locale == 'ka'}.first
    cit.name_abbrv = 'გაერთიანებული ოპოზიცია'
    cit.description = 'ხმების გადანაწილება, გაერთიანებული ოპოზიცია (%)'
		cit.save

    cits = CoreIndicatorTranslation.where(:core_indicator_id => 55)
		cit = cits.select{|x| x.locale == 'en'}.first
    cit.name_abbrv = 'Vashadze'
    cit.description = 'Vote share Tamaz Vashadze (%)'
		cit.save
		cit = cits.select{|x| x.locale == 'ka'}.first
    cit.name_abbrv = 'ვაშაძე'
    cit.description = 'ხმების გადანაწილება, თამაზ ვაშაძე (%)'
		cit.save

    cits = CoreIndicatorTranslation.where(:core_indicator_id => 62)
		cit = cits.select{|x| x.locale == 'en'}.first
    cit.name_abbrv = 'We Ourselves'
    cit.description = 'Vote share We Ourselves (%)'
		cit.save
		cit = cits.select{|x| x.locale == 'ka'}.first
    cit.name_abbrv = 'ჩვენ თვითონ'
    cit.description = 'ხმების გადანაწილება, ჩვენ თვითონ (%)'
		cit.save

    ###########
    cits = CoreIndicatorTranslation.where(:core_indicator_id => 13)
		cit = cits.select{|x| x.locale == 'en'}.first
    cit.name_abbrv = '85-99 Years Old'
    cit.description = 'Number of voters between 85 and 99 years old'
		cit.save
		cit = cits.select{|x| x.locale == 'ka'}.first
    cit.name_abbrv = '85-99 წლის'
    cit.description = 'ამომრჩეველთა რაოდენობა 85 და 99 წელს შორის'
		cit.save

    cits = CoreIndicatorTranslation.where(:core_indicator_id => 14)
		cit = cits.select{|x| x.locale == 'en'}.first
    cit.name_abbrv = 'Over 99 Years Old'
    cit.description = 'Numbers of voters over 99 years old'
		cit.save
		cit = cits.select{|x| x.locale == 'ka'}.first
    cit.name_abbrv = '99 წელზე მეტი'
    cit.description = 'ამომრჩეველთა რაოდენობა 99 წელს ზემოთ'
		cit.save

    cits = CoreIndicatorTranslation.where(:core_indicator_id => 1)
		cit = cits.select{|x| x.locale == 'en'}.first
    cit.name_abbrv = 'Average Age'
    cit.description = 'Average age of voters'
		cit.save
		cit = cits.select{|x| x.locale == 'ka'}.first
    cit.name_abbrv = 'საშუალო ასაკი'
    cit.description = 'ამომრჩეველთა საშუალო ასაკი'
		cit.save

    cits = CoreIndicatorTranslation.where(:core_indicator_id => 12)
		cit = cits.select{|x| x.locale == 'en'}.first
    cit.name_abbrv = 'Duplications'
    cit.description = 'Number of voter duplications'
		cit.save
		cit = cits.select{|x| x.locale == 'ka'}.first
    cit.name_abbrv = 'დუბლირებული'
    cit.description = 'დუბლირებულ ამომრჩეველთა რაოდენობა'
		cit.save

    cits = CoreIndicatorTranslation.where(:core_indicator_id => 15)
		cit = cits.select{|x| x.locale == 'en'}.first
    cit.name_abbrv = 'Total Turnout (#)'
    cit.description = 'Total Turnout (#)'
		cit.save
		cit = cits.select{|x| x.locale == 'ka'}.first
    cit.name_abbrv = 'აქტივობა (#)'
    cit.description = 'აქტივობა (#)'
		cit.save

    cits = CoreIndicatorTranslation.where(:core_indicator_id => 16)
		cit = cits.select{|x| x.locale == 'en'}.first
    cit.name_abbrv = 'Total Turnout (%)'
    cit.description = 'Total Turnout (%)'
		cit.save
		cit = cits.select{|x| x.locale == 'ka'}.first
    cit.name_abbrv = 'აქტივობა (%)'
    cit.description = 'აქტივობა (%)'
		cit.save

    cits = CoreIndicatorTranslation.where("core_indicator_id in (2,3,4,5,6) and locale='ka'")
    cits.each do |cit|
      cit.name_abbrv = cit.name_abbrv.gsub('VPM','ხმის მიცემა წუთში')
      cit.description = cit.description.gsub('ხმების რაოდენობა ერთ წუთში', 'წუთში ხმის მიცემის საშუალო რაოდენობა')
  		cit.save
    end
    
    cits = CoreIndicatorTranslation.where("core_indicator_id in (7,8,9,10,11) and locale='ka'")
    cits.each do |cit|
      cit.name_abbrv = cit.name_abbrv.gsub('VPM','ხმის მიცემა წუთში')
      cit.description = cit.description.gsub('ხმების რაოდენობა ერთ წუთში', 'საარჩევნო უბნების რაოდენობა, სადაც ხმის მიცემის რაოდენობა წუთში > 3')
  		cit.save
    end
    
  end

  def down
		# do nothing
  end
end
