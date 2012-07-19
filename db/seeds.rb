# encoding: utf-8

# Event Types **************************************************************************
EventType.destroy_all

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

st = ShapeType.create(:id => 7, :ancestry => '1/2/3')
st.shape_type_translations.create(:locale=>"ka", :name_singular=>"თბილისი ოლქი", :name_plural=>"თბილისი ოლქები")
st.shape_type_translations.create(:locale=>"en", :name_singular=>"Tbilisi District", :name_plural=>"Tbilisi Districts")
st = ShapeType.create(:id => 8, :ancestry => '1/2/3/7')
st.shape_type_translations.create(:locale=>"ka", :name_singular=>"თბილისი საუბნო", :name_plural=>"თბილისი საუბნოები")
st.shape_type_translations.create(:locale=>"en", :name_singular=>"Tbilisi Precinct", :name_plural=>"Tbilisi Precincts")
st = ShapeType.create(:id => 9, :ancestry => '1/2/3/7')
st.shape_type_translations.create(:locale=>"ka", :name_singular=>"მაჟორიტარიული თბილისი ოლქი", :name_plural=>"მაჟორიტარიული თბილისი ოლქები")
st.shape_type_translations.create(:locale=>"en", :name_singular=>"Majoritarian Tbilisi District", :name_plural=>"Majoritarian Tbilisi Districts")
st = ShapeType.create(:id => 10, :ancestry => '1/2/3/7/9')
st.shape_type_translations.create(:locale=>"ka", :name_singular=>"მაჟორიტარიული თბილისი საუბნო", :name_plural=>"მაჟორიტარიული თბილისი საუბნოები")
st.shape_type_translations.create(:locale=>"en", :name_singular=>"Majoritarian Tbilisi Precinct", :name_plural=>"Majoritarian Tbilisi Precincts")



# Pages **************************************************************************

Page.destroy_all

page = Page.create(:name => 'about')
page.page_translations.create(:locale => 'ka', :title => '', :description => '...')
page.page_translations.create(:locale => 'en', :title => '', :description => '...')
page = Page.create(:name => 'terms')
page.page_translations.create(:locale => 'ka', :title => '', :description => '...')
page.page_translations.create(:locale => 'en', :title => '', :description => '...')
page = Page.create(:name => 'export_help')
page.page_translations.create(:locale => 'ka', :title => '', :description => '...')
page.page_translations.create(:locale => 'en', :title => '', :description => '...')
page = Page.create(:name => 'data_source')
page.page_translations.create(:locale => 'ka', :title => '', :description => '...')
page.page_translations.create(:locale => 'en', :title => '', :description => '...')


# Indicator Types **************************************************************************
IndicatorType.destroy_all

it = IndicatorType.create(:id => 1, :has_summary => false)
it.indicator_type_translations.create(:locale=>"ka", :name => "ინდიკატორები")
it.indicator_type_translations.create(:locale=>"en", :name=>"Indicators")
it = IndicatorType.create(:id => 2, :has_summary => true)
it.indicator_type_translations.create(:locale=>"ka", :name => "საერთო შედეგები")
it.indicator_type_translations.create(:locale=>"en", :name=>"Overall Results")
