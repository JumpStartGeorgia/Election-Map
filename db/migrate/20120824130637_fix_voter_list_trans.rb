# encoding: utf-8
class FixVoterListTrans < ActiveRecord::Migration
  def up
		# set the name = to the desc for ka
		trans = CoreIndicatorTranslation.where("locale = 'ka' and core_indicator_id in (12,13,14, 1)")
		trans.each do |t|
			t.name = t.description
			t.save
		end
  end

  def down
		# do nothing
  end
end
