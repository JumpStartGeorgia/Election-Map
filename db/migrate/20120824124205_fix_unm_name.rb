# encoding: utf-8
class FixUnmName < ActiveRecord::Migration
  def up
		trans = CoreIndicatorTranslation.where(:locale => 'ka', :name => 'ნაც. მოძრაობა')
		if trans && !trans.empty?
			trans.first.description = 'ხმების გადანაწილება, ერთიანი ნაციონალური მოძრაობა (%)'
			trans.first.save
		end
  end

  def down
		trans = CoreIndicatorTranslation.where(:locale => 'ka', :name => 'ნაც. მოძრაობა')
		if trans && !trans.empty?
			trans.first.description = 'ხმების გადანაწილება, ნაც. მოძრაობა (%)'
			trans.first.save
		end
  end
end
