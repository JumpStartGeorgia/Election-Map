# encoding: utf-8
class Update2010BielecDescription < ActiveRecord::Migration
  def up
		event = Event.find(17)
		#fix the data
		event.event_date = '2010-05-30'
		event.save
		# fix the descriptions
		en = event.event_translations.select{|x| x.locale == 'en'}.first
		en.description = 'The results of the May 30, 2010 elections in Chugureti district 7, Gurjaani district 12 and Ozurgeti district 60 for a vacant majoritarian seats in Parliament.'
		en.save
		ka = event.event_translations.select{|x| x.locale == 'ka'}.first
		ka.description = '2010 წლის 30 მაისის შუალედური საპარლამენტო არჩევნების შედეგები ჩუღურეთის მე-7, გურჯაანის მე-12 და ოზურგეთის 60-ე ოლქებში ვაკანტური მაჟორიტარული ადგილებისათვის.'
		ka.save
  end

  def down
		# do nothing
  end
end
