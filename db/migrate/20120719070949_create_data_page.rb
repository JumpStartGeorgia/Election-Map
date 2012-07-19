# encoding: utf-8

class CreateDataPage < ActiveRecord::Migration
  def up
		page = Page.create(:name => 'data_source')
		page.page_translations.create(:locale => 'ka', :title => 'მონაცემთა წყარო', :description => 'საარჩევნო მონაცემები საჯარო მონაცემებით ცენტრალურმა საარჩევნო კომისიამ საქართველოს. ... რუკა ფორმები შეიქმნა ცენტრალური საარჩევნო კომისია საქართველოს. ...')
		page.page_translations.create(:locale => 'en', :title => 'Data Source', :description => 'The election data is public data provided by the Central Election Commission of Georgia (CEC).  ....  The map shapes were created by the CEC. ...')
  end

  def down
		Page.destroy_all(:name => 'data_source')
  end
end
