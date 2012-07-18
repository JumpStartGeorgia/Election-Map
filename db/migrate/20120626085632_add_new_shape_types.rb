# encoding: utf-8

class AddNewShapeTypes < ActiveRecord::Migration
  def up
		ShapeType.where(:id => 7..10).destroy_all

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
  end

  def down
		# delete the shape types
		ShapeType.where(:id => 7..10).destroy_all
  end
end
