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
ShapeType.destroy_all

st = ShapeType.create(:id => 1)
st.shape_type_translations.create(:locale=>"ka", :name_singular=>"ქვეყანა", :name_plural=>"ქვეყნები")
st.shape_type_translations.create(:locale=>"en", :name_singular=>"Country", :name_plural=>"Countries")
st = ShapeType.create(:id => 2, :ancestry => '1')
st.shape_type_translations.create(:locale=>"ka", :name_singular=>"რეგიონი", :name_plural=>"რეგიონები")
st.shape_type_translations.create(:locale=>"en", :name_singular=>"Region", :name_plural=>"Regions")
st = ShapeType.create(:id => 3, :ancestry => '1/2')
st.shape_type_translations.create(:locale=>"ka", :name_singular=>"ოლქი", :name_plural=>"ოლქები")
st.shape_type_translations.create(:locale=>"en", :name_singular=>"District", :name_plural=>"Districts")
st = ShapeType.create(:id => 4, :ancestry => '1/2/3')
st.shape_type_translations.create(:locale=>"ka", :name_singular=>"საუბნო", :name_plural=>"საუბნოები")
st.shape_type_translations.create(:locale=>"en", :name_singular=>"Precinct", :name_plural=>"Precincts")
st = ShapeType.create(:id => 5, :ancestry => '1/2/3')
st.shape_type_translations.create(:locale=>"ka", :name_singular=>"მაჟორიტარიული ოლქი", :name_plural=>"მაჟორიტარიული ოლქები")
st.shape_type_translations.create(:locale=>"en", :name_singular=>"Majoritarian District", :name_plural=>"Majoritarian Districts")
st = ShapeType.create(:id => 6, :ancestry => '1/2/3/5')
st.shape_type_translations.create(:locale=>"ka", :name_singular=>"მაჟორიტარიული საუბნო", :name_plural=>"მაჟორიტარიული საუბნოები")
st.shape_type_translations.create(:locale=>"en", :name_singular=>"Majoritarian Precinct", :name_plural=>"Majoritarian Precincts")



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


