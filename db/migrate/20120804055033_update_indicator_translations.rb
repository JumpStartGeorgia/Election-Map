class UpdateIndicatorTranslations < ActiveRecord::Migration
  def up
		core_indicator_translations = CoreIndicatorTranslation.where(:locale => 'en')


    cits = CoreIndicatorTranslation.where(core_indicator_id = 34)
		cit = cits.select{|x| x.locale == 'en'}
    cit.name_abbrv = 'Alasania'
    cit.description = 'Vote share Irakli Alasania (%)'
		cit.save
		cit = cits.select{|x| x.locale == 'ka'}
    cit.name_abbrv = 'ალასანია'
    cit.description = 'ხმების გადანაწილება, ირაკლი ალასანია (%)'
		cit.save

    cits = CoreIndicatorTranslation.where(core_indicator_id = 18)
		cit = cits.select{|x| x.locale == 'en'}
    cit.name_abbrv = 'Alliance'
    cit.description = 'Vote share Alliance for Georgia (%)'
		cit.save
		cit = cits.select{|x| x.locale == 'ka'}
    cit.name_abbrv = 'ალიანსი'
    cit.description = 'ხმების გადანაწილება, ალიანსი საქართველოსთვის (%)'
		cit.save

    cits = CoreIndicatorTranslation.where(core_indicator_id = 21)
		cit = cits.select{|x| x.locale == 'en'}
    cit.name_abbrv = 'CDA'
    cit.description = 'Vote share Christian Democratic Alliance (%)'
		cit.save
		cit = cits.select{|x| x.locale == 'ka'}
    cit.name_abbrv = 'ქრისტიან-დემოკრატიული ალიანსი'
    cit.description = 'ხმების გადანაწილება, ქრისტიან-დემოკრატიული ალიანსი (%)'
		cit.save

    cits = CoreIndicatorTranslation.where(core_indicator_id = 20)
		cit = cits.select{|x| x.locale == 'en'}
    cit.name_abbrv = 'CDM'
    cit.description = 'Vote share Christian-Democratic Movement (%)'
		cit.save
		cit = cits.select{|x| x.locale == 'ka'}
    cit.name_abbrv = 'ქდმ'
    cit.description = 'ხმების გადანაწილება, ქრისტიანულ-დემოკრატიული მოძრაობა (%)'
		cit.save

    cits = CoreIndicatorTranslation.where(core_indicator_id = 30)
		cit = cits.select{|x| x.locale == 'en'}
    cit.name_abbrv = 'Chanturia'
    cit.description = 'Vote share Giorgi Chanturia (%)'
		cit.save
		cit = cits.select{|x| x.locale == 'ka'}
    cit.name_abbrv = 'ჭანტურია'
    cit.description = 'ხმების გადანაწილება, გია ჭანტურია (%)'
		cit.save

    cits = CoreIndicatorTranslation.where(core_indicator_id = 63)
		cit = cits.select{|x| x.locale == 'en'}
    cit.name_abbrv = 'Dzidziguri'
    cit.description = 'Vote share Zviad Dzidziguri (%)'
		cit.save
		cit = cits.select{|x| x.locale == 'ka'}
    cit.name_abbrv = 'ძიძიგური'
    cit.description = 'ხმების გადანაწილება, ზვიად ძიძიგური (%)'
		cit.save

    cits = CoreIndicatorTranslation.where(core_indicator_id = 25)
		cit = cits.select{|x| x.locale == 'en'}
    cit.name_abbrv = 'Future Geo.'
    cit.description = 'Vote share Future Georgia (%)'
		cit.save
		cit = cits.select{|x| x.locale == 'ka'}
    cit.name_abbrv = 'მომავალი საქართველო'
    cit.description = 'ხმების გადანაწილება, მომავალი საქართველო (%)'
		cit.save

    cits = CoreIndicatorTranslation.where(core_indicator_id = 24)
		cit = cits.select{|x| x.locale == 'en'}
    cit.name_abbrv = 'Freedom'
    cit.description = 'Vote share Freedom Party (%)'
		cit.save
		cit = cits.select{|x| x.locale == 'ka'}
    cit.name_abbrv = 'თავისუფლება'
    cit.description = 'ხმების გადანაწილება, თავისუფლება (%)'
		cit.save

    cits = CoreIndicatorTranslation.where(core_indicator_id = 37)
		cit = cits.select{|x| x.locale == 'en'}
    cit.name_abbrv = 'Gachechiladze'
    cit.description = 'Vote share Levan Gachechiladze (%)'
		cit.save
		cit = cits.select{|x| x.locale == 'ka'}
    cit.name_abbrv = 'გაჩეჩილაძე'
    cit.description = 'ხმების გადანაწილება, ლევან გაჩეჩილაძე (%)'
		cit.save

    cits = CoreIndicatorTranslation.where(core_indicator_id = 22)
		cit = cits.select{|x| x.locale == 'en'}
    cit.name_abbrv = 'Gamkrelidze'
    cit.description = 'Vote share Davit Gamkrelidze (%)'
		cit.save
		cit = cits.select{|x| x.locale == 'ka'}
    cit.name_abbrv = 'გამყრელიძე'
    cit.description = 'ხმების გადანაწილება, დავით გამყრელიძე (%)'
		cit.save

    cits = CoreIndicatorTranslation.where(core_indicator_id = 26)
		cit = cits.select{|x| x.locale == 'en'}
    cit.name_abbrv = 'Geo. Group'
    cit.description = 'Vote share Georgian Group (%)'
		cit.save
		cit = cits.select{|x| x.locale == 'ka'}
    cit.name_abbrv = 'ქართული დასი'
    cit.description = 'ხმების გადანაწილება, ქართული დასი (%)'
		cit.save

    cits = CoreIndicatorTranslation.where(core_indicator_id = 27)
		cit = cits.select{|x| x.locale == 'en'}
    cit.name_abbrv = 'Geo. Politics'
    cit.description = 'Vote share Georgian Politics (%)'
		cit.save
		cit = cits.select{|x| x.locale == 'ka'}
    cit.name_abbrv = 'ქართული პოლიტიკა'
    cit.description = 'ხმების გადანაწილება, ქართული პოლიტიკა (%)'
		cit.save

    cits = CoreIndicatorTranslation.where(core_indicator_id = 23)
		cit = cits.select{|x| x.locale == 'en'}
    cit.name_abbrv = 'Iakobidze'
    cit.description = 'Vote share Davit Iakobidze (%)'
		cit.save
		cit = cits.select{|x| x.locale == 'ka'}
    cit.name_abbrv = 'იაკობიძე'
    cit.description = 'ხმების გადანაწილება, დავით იაკობიძე (%)'
		cit.save

    cits = CoreIndicatorTranslation.where(core_indicator_id = 33)
		cit = cits.select{|x| x.locale == 'en'}
    cit.name_abbrv = 'Industry'
    cit.description = 'Vote share Industry Will Save Georgia (%)'
		cit.save
		cit = cits.select{|x| x.locale == 'ka'}
    cit.name_abbrv = 'მრეწველები'
    cit.description = 'ხმების გადანაწილება, მრეწველობა გადაარჩენს საქართველოს (%)'
		cit.save

    cits = CoreIndicatorTranslation.where(core_indicator_id = 36)
		cit = cits.select{|x| x.locale == 'en'}
    cit.name_abbrv = 'Labour'
    cit.description = 'Vote share Labour (%)'
		cit.save
		cit = cits.select{|x| x.locale == 'ka'}
    cit.name_abbrv = 'ლეიბორისტები'
    cit.description = 'ხმების გადანაწილება, ლეიბორისტული პარტია (%)'
		cit.save

    cits = CoreIndicatorTranslation.where(core_indicator_id = 31)
		cit = cits.select{|x| x.locale == 'en'}
    cit.name_abbrv = 'Laghidze'
    cit.description = 'Vote share Giorgi Laghidze (%)'
		cit.save
		cit = cits.select{|x| x.locale == 'ka'}
    cit.name_abbrv = 'ლაღიძე'
    cit.description = 'ხმების გადანაწილება, გიორგი ლაღიძე (%)'
		cit.save

    cits = CoreIndicatorTranslation.where(core_indicator_id = 29)
		cit = cits.select{|x| x.locale == 'en'}
    cit.name_abbrv = 'Maisashvili'
    cit.description = 'Vote share Giorgi (Gia) Maisashvili (%)'
		cit.save
		cit = cits.select{|x| x.locale == 'ka'}
    cit.name_abbrv = 'მაისაშვილი'
    cit.description = 'ხმების გადანაწილება, გიორგი (გია) მაისაშვილი (%)'
		cit.save

    cits = CoreIndicatorTranslation.where(core_indicator_id = 38)
		cit = cits.select{|x| x.locale == 'en'}
    cit.name_abbrv = 'Mamulishvili'
    cit.description = 'Vote share Mamulishvili (%)'
		cit.save
		cit = cits.select{|x| x.locale == 'ka'}
    cit.name_abbrv = 'მამულიშვილი'
    cit.description = 'ხმების გადანაწილება, მამულიშვილი (%)'
		cit.save

    cits = CoreIndicatorTranslation.where(core_indicator_id = 40)
		cit = cits.select{|x| x.locale == 'en'}
    cit.name_abbrv = 'For Fair Georgia'
    cit.description = 'Vote share Movement for Fair Georgia (%)'
		cit.save
		cit = cits.select{|x| x.locale == 'ka'}
    cit.name_abbrv = 'სამართლიანი საქართველოსთვის'
    cit.description = 'ხმების გადანაწილება, მოძრაობა სამართლიანი საქართველოსთვის (%)'
		cit.save

    cits = CoreIndicatorTranslation.where(core_indicator_id = 45)
		cit = cits.select{|x| x.locale == 'en'}
    cit.name_abbrv = 'N. Ivanishvili'
    cit.description = 'Vote share Nikoloz Ivanishvili (%)'
		cit.save
		cit = cits.select{|x| x.locale == 'ka'}
    cit.name_abbrv = 'ნ. ივანიშვილი'
    cit.description = 'ხმების გადანაწილება, ნიკოლოზ ივანიშვილი (%)'
		cit.save

    cits = CoreIndicatorTranslation.where(core_indicator_id = 46)
		cit = cits.select{|x| x.locale == 'en'}
    cit.name_abbrv = 'Public Democrats'
    cit.description = 'Vote share Nikoloz Ivanishvili Public Democrats (%)'
		cit.save
		cit = cits.select{|x| x.locale == 'ka'}
    cit.name_abbrv = 'სახალხო დემოკრატები'
    cit.description = 'ხმების გადანაწილება, ნიკოლოზ ივანიშვილი სახალხო დემოკრატები (%)'
		cit.save

    cits = CoreIndicatorTranslation.where(core_indicator_id = 52)
		cit = cits.select{|x| x.locale == 'en'}
    cit.name_abbrv = 'Natelashvili'
    cit.description = 'Vote share Shalva Natelashvili (%)'
		cit.save
		cit = cits.select{|x| x.locale == 'ka'}
    cit.name_abbrv = 'ნათელაშვილი'
    cit.description = 'ხმების გადანაწილება, შალვა ნათელაშვილი (%)'
		cit.save

    cits = CoreIndicatorTranslation.where(core_indicator_id = 41)
		cit = cits.select{|x| x.locale == 'en'}
    cit.name_abbrv = 'Nat. Council'
    cit.description = 'Vote share National Council (%)'
		cit.save
		cit = cits.select{|x| x.locale == 'ka'}
    cit.name_abbrv = 'ეროვნული საბჭო'
    cit.description = 'ხმების გადანაწილება, ეროვნული საბჭო (%)'
		cit.save

    cits = CoreIndicatorTranslation.where(core_indicator_id = 43)
		cit = cits.select{|x| x.locale == 'en'}
    cit.name_abbrv = 'NDP'
    cit.description = 'Vote share National Democratic Party of Georgia (%)'
		cit.save
		cit = cits.select{|x| x.locale == 'ka'}
    cit.name_abbrv = 'ედპ'
    cit.description = 'ხმების გადანაწილება, საქართველოს ეროვნულ დემოკრატიული პარტია (%)'
		cit.save

    cits = CoreIndicatorTranslation.where(core_indicator_id = 64)
		cit = cits.select{|x| x.locale == 'en'}
    cit.name_abbrv = 'New Rights'
    cit.description = 'Vote share New Rights (%)'
		cit.save
		cit = cits.select{|x| x.locale == 'ka'}
    cit.name_abbrv = 'ახალი მემარჯვენეები'
    cit.description = 'ხმების გადანაწილება, ახალი მემარჯვენეები (%)'
		cit.save

    cits = CoreIndicatorTranslation.where(core_indicator_id = 44)
		cit = cits.select{|x| x.locale == 'en'}
    cit.name_abbrv = 'NPRDG'
    cit.description = 'Vote share National Party of Radical Democrats of Georgia (%)'
		cit.save
		cit = cits.select{|x| x.locale == 'ka'}
    cit.name_abbrv = 'რადიკალ-დემოკრატები'
    cit.description = 'ხმების გადანაწილება, სრულიად საქართველოს რადიკალ დემოკრატთა ნაციონალური პარტია (%)'
		cit.save

  end

  def down
		# do nothing
  end
end
