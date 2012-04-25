# encoding: utf-8
# Locales **************************************************************************

Locale.delete_all

Locale.create(:language => 'ka' , :name => 'ქართული')
Locale.create(:language => 'en' , :name => 'English')

# Event Types **************************************************************************
EventType.delete_all
EventTypeTranslation.delete_all

EventType.create(:event_type_translations_attributes => {"0"=>{:name=>"არჩევნები", :locale=>"ka"}, "1"=>{:name=>"Elections", :locale=>"en"}})
EventType.create(:event_type_translations_attributes => {"0"=>{:name=>"ამომრჩეველთა სია", :locale=>"ka"}, "1"=>{:name=>"Voters List", :locale=>"en"}})

# Shape Types **************************************************************************
ShapeType.delete_all
ShapeTypeTranslation.delete_all

ShapeType.create(:shape_type_translations_attributes => {"0"=>{:name=>"ქვეყანა", :locale=>"ka"}, "1"=>{:name=>"Country", :locale=>"en"}})
ShapeType.create(:ancestry => '1', :shape_type_translations_attributes => {"0"=>{:name=>"რეგიონში", :locale=>"ka"}, "1"=>{:name=>"Region", :locale=>"en"}})
ShapeType.create(:ancestry => '1/2', :shape_type_translations_attributes => {"0"=>{:name=>"რაიონის", :locale=>"ka"}, "1"=>{:name=>"District", :locale=>"en"}})
ShapeType.create(:ancestry => '1/2/3', :shape_type_translations_attributes => {"0"=>{:name=>"საუბნო", :locale=>"ka"}, "1"=>{:name=>"Precinct", :locale=>"en"}})

# Pages **************************************************************************

Page.delete_all

page = Page.create(:name => 'about')
page.page_translations.create(:locale => 'ka', :description => '...')
page.page_translations.create(:locale => 'en', :description => '...')
page = Page.create(:name => 'terms')
page.page_translations.create(:locale => 'ka', :description => '...')
page.page_translations.create(:locale => 'en', :description => '...')
page = Page.create(:name => 'export_help')
page.page_translations.create(:locale => 'ka', :description => '...')
page.page_translations.create(:locale => 'en', :description => '...')
