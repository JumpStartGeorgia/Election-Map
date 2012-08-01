# encoding: utf-8
class FixEventTypeNames < ActiveRecord::Migration
  def up
		# clean up the event type names

		event_type_translations = EventTypeTranslation.where(:locale => 'ka')
		# pres
    ett = event_type_translations.select{|x| x.event_type_id == 1}.first
    ett.name = 'საპრეზიდენტო'
		ett.save
  end

  def down
		# do nothing
  end
end
