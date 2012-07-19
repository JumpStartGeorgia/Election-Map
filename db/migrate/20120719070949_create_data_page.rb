class CreateDataPage < ActiveRecord::Migration
  def up
		page = Page.create(:name => 'data_source')
		page.page_translations.create(:locale => 'ka', :description => '')
		page.page_translations.create(:locale => 'en', :description => 'The election data is public data provided by the CEC.  ....  The shapes were created by the CEC.')
  end

  def down
		Page.destroy(:name => 'data_source')
  end
end
