# encoding: utf-8
class FixCustomViewKaFootnote < ActiveRecord::Migration
  def up
		trans = EventCustomViewTranslation.where(:locale => 'ka')
		trans.each do |t|
			t.note = 'თბილისის ოლქების სანახავად დააჭირეთ თბილისს.'
			t.save
		end
  end

  def down
		trans = EventCustomViewTranslation.where(:locale => 'ka')
		trans.each do |t|
			t.note = 'თბილისის რაიონები უკვე ერთიანი ამ მხრივ. რაიონების სანახავად დაწკაპეთ "თბილისი".'
			t.save
		end
  end
end
