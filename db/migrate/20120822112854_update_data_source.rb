# encoding: utf-8
class UpdateDataSource < ActiveRecord::Migration
  def up
		# data source
		page = Page.where(:name => 'data_source').first
		x = page.page_translations.select{|x| x.locale == 'en'}.first
		x.description = 'All of the Voter List and elections data was obtained by public information requests to the Central Election Commission of Georgia since 2008. The CEC can be found at <a href="http://www.cec.gov.ge" target="_blank" title="go to their site">http://www.cec.gov.ge</a>.

All of the original shapefiles and geographic data were obtained from the Caucasus Research Resource Center (CRRC). The CRRC can be found at <a href="http://www.crrc.ge" target="_blank" title="go to their site">http://www.crrc.ge</a>.'
		x.save
		x = page.page_translations.select{|x| x.locale == 'ka'}.first
		x.description = 'ამომრჩეველთა სიისა და არჩევნების მონაცემები მოპოვებულია 2008 წლიდან ცესკოსგან საჯარო ინფორმაციის გამოთხოვის მეთოდით. ცესკოს ვებ-გვერდის მისამართია: <a href="http://www.cec.gov.ge" target="_blank">http://www.cec.gov.ge</a>.'
		x.save
  end

  def down
		# do nothing
  end
end
