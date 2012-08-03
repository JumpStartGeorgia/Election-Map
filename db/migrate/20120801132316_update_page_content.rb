# encoding: utf-8

class UpdatePageContent < ActiveRecord::Migration
  def up
		# fix the content for the page objects

		# export help
		page = Page.where(:name => 'export_help').first
		x = page.page_translations.select{|x| x.locale == 'en'}.first
		x.description = 'You can export the map in two ways.

1 - SVG. You can click on the button labeled \'SVG\' to download an SVG image of the map. SVG is similar to an image, but it contains layers that you can interact with. For example, you can change colors, add text, move shapes, etc. You can use a free application called Inkscape to edit these SVG files and save them into different formats like PDF and PNG.

2 - XLS. You can click on the button labeled \'XLS\' to download the data into a spreadsheet. This data download will include all data for the selected event at the selected map level. For example, if you are looking at 2008 Presidential Elections at the Region level, the \'XLS\' button will download data for 2008 Presidential Elections for all Regions.'
		x.save
		x = page.page_translations.select{|x| x.locale == 'ka'}.first
		x.description = 'რუკის ექსპორტი შესაძლებელია ორი სახით.

1 - SVG. რუკის სურათად გადმოსაწერად დააჭირეთ მარჯვენა ქვედა კუთხეში ღილაკს "SVG". SVG-ით იმავე გამოსახულებას მიიღებთ, რაც რუკაზეა, ამასთან მას აქვს დამატებითი ფუნქციები რითაც შეგიძლიათ ისარგებლოთ. მაგალითად, შეგიძლიათ შეცვალოთ ფერები, დაამატოთ ტექსტი, გადაანაცვლოთ საზღვრები და ა.შ. ამისათვის შეგიძლიათ გამოიყენოთ უფასო აპლიკაცია სახელად "Inkscape", განახორციელოთ ცვლილებები SVG ფაილში და შეინახოთ სხვადასხვა ფორმატში როგორიცაა PDF ან PNG.

2 - XLS. მონაცემების ცხრილის ფორმატში გადმოსაწერად დააჭირეთ მარჯვენა ქვედა კუთხეში ღილაკს "XLS". გადმოწერილი მონაცემები იქნება არჩეული საკითხისა და რუკის შესაბამისი ზონის ამსახველი. მაგალითად, თუ უყურებთ 2008 წლის საპრეზიდენტო არჩევნებს რეგიონალურ დონეზე, "XLS" ღილაკი გადმოწერს 2008 წლის საპრეზიდენტო არჩევნების მონაცემებს საქართველოს ყველა რეგიონისთვის.'
		x.save

		# about
		page = Page.where(:name => 'about').first
		x = page.page_translations.select{|x| x.locale == 'en'}.first
		x.description = 'This website was created by Jumpstart Georgia for the National Democratic Institute (NDI) with the support of the Swedish International Development and Cooperation Agency (Sida). The purpose of this site is to make Voter’s List and elections data more accessible. Jumpstart Georiga can be found at <a href="http://www.jumpstart.ge" target="_blank">http://www.jumpstart.ge</a>. NDI can be found at <a href="http://www.ndi.org" target="_blank">http://www.ndi.org</a>. Sida can be found at <a href="http://www.sida.se" target="_blank">http://www.sida.se</a>.'
		x.save
		x = page.page_translations.select{|x| x.locale == 'ka'}.first
		x.description = 'ვებ-გვერდი შექმნილია ჯამპსტარტ ჯორჯიას მიერ ეროვნულ დემოკრატიული ინსტიტუტის (NDI) დაკვეთით. ვებ-გვერდი დაფინანსებულია შვედეთის საერთაშორისო განვითარების თანამშრომლობის სააგენტოს (Sida) მიერ. ჯამპსტარტ ჯორჯიას ვებ-გვერდის მისამართია: <a href="http://www.jumpstart.ge" target="_blank">http://www.jumpstart.ge</a>. NDI-ს ვებ-გვერდის მისამართია: <a href="http://www.ndi.org" target="_blank">http://www.ndi.org</a>. Sida-ს ვებ-გვერდის მისამართია: <a href="http://www.sida.se" target="_blank">http://www.sida.se</a>.'
		x.save

		# data source
		page = Page.where(:name => 'data_source').first
		x = page.page_translations.select{|x| x.locale == 'en'}.first
		x.description = 'All of the Voter List and elections data was obtained by public information requests to the Central Election Commission of Georgia since 2008. The CEC can be found at <a href="http://www.cec.gov.ge" target="_blank" title="go to their site">http://www.cec.gov.ge</a>.'
		x.save
		x = page.page_translations.select{|x| x.locale == 'ka'}.first
		x.description = 'ამომრჩეველთა სიისა და არჩევნების მონაცემები მოპოვებულია 2008 წლიდან ცესკოსგან საჯარო ინფორმაციის გამოთხოვის მეთოდით. ცესკოს ვებ-გვერდის მისამართია: <a href="http://www.cec.gov.ge" target="_blank">http://www.cec.gov.ge</a>.'
		x.save

  end

  def down
		# do nothing
  end
end
