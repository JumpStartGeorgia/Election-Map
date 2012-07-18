# encoding: utf-8

class AddFootnoteCustomViews < ActiveRecord::Migration
  def up
    EventCustomView.create_translation_table! :note => :string
    add_index :event_custom_view_translations, :note

		# add note to existing records
		EventCustomView.all.each do |custom_view|
			custom_view.event_custom_view_translations.create(:locale=>"ka", :note=>"თბილისის რაიონები უკვე ერთიანი ამ მხრივ. რაიონების სანახავად დაწკაპეთ \"თბილისი\".")
			custom_view.event_custom_view_translations.create(:locale=>"en", :note=>"Tbilisi districts have been aggregated in this view. Click on Tbilisi to view it's districts.")
		end
  end

  def down
    EventCustomView.drop_translation_table!
  end
end
