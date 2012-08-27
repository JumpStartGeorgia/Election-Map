# encoding: utf-8
class FixVpmKaNames < ActiveRecord::Migration
  def up
		# update vpm name and desc
		trans = CoreIndicatorTranslation.where("locale = 'ka' and name like 'ხმების რაოდენობა ერთ წუთში%'")
		trans.each do |t|
      t.name = t.name.gsub('ხმების რაოდენობა ერთ წუთში', 'უბნების რაოდენობა, სადაც ხმის მიცემა წუთში > 3')
      t.description = t.description.gsub('საარჩევნო უბნების რაოდენობა, სადაც ხმის მიცემის რაოდენობა წუთში > 3', 'უბნების რაოდენობა, სადაც ხმის მიცემა წუთში > 3')
			t.save
		end
  end

  def down
		# do nothing
  end
end
