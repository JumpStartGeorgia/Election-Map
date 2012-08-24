# encoding: utf-8
class UpdateDatasourceAgain < ActiveRecord::Migration
  def up
		# data source
		page = Page.where(:name => 'data_source').first
		x = page.page_translations.select{|x| x.locale == 'en'}.first
		x.description = 'All of the Voter List and elections data were obtained by public information requests to the Central Election Commission of Georgia since 2008. The CEC can be found at <a href="http://www.cec.gov.ge" target="_blank" title="go to their site">http://www.cec.gov.ge</a>.

All of the original shapefiles outlining electoral geographic boundaries were obtained from the Caucasus Research Resource Center (CRRC). The CRRC can be found at <a href="http://www.crrc.ge" target="_blank" title="go to their site">http://www.crrc.ge</a>.

All of the base layer data, including street data, were obtained from JumpStart Georgia. JumpStart Georgia can be found at <a href="http://www.jumpstart.ge" target="_blank" title="go to their site">http://www.jumpstart.ge</a>.'
		x.save
		x = page.page_translations.select{|x| x.locale == 'ka'}.first
		x.description = 'ამომრჩეველთა სიისა და არჩევნების მონაცემები მოპოვებულია 2008 წლიდან ცესკოსგან საჯარო ინფორმაციის გამოთხოვის მეთოდით. ცესკოს ვებ-გვერდის მისამართია: <a href="http://www.cec.gov.ge" target="_blank">http://www.cec.gov.ge</a>.

გეოგრაფიული მონაცემები მოწოდებულია კავკასიის კვლევითი რესურსების ცენტრის (CRRC) მიერ. CRRC-ს ვებ გვერდის მისამართია: <a href="http://www.crrc.ge" target="_blank">http://www.crrc.ge</a>.'
		x.save
  end

  def down
		# do nothing
  end
end
