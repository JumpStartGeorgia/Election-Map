class LoadUniqueDistrictNames < ActiveRecord::Migration
  def up
    # get districts and tbilisi districts
    shape_type_ids = [3,7]
    shapes = Shape.joins(:shape_translations)
              .select('distinct shapes.shape_type_id, shape_translations.locale as locale, shape_translations.common_id as c_id, shape_translations.common_name as c_name')
              .where("shape_translations.common_id != '0' and shapes.shape_type_id in (?) ", shape_type_ids)
              .order("shape_translations.common_name asc")
puts "found #{shapes.length} shapes"

    shapes.map{|x| x[:c_id]}.uniq.each do |id|
      en = shapes.select{|x| x[:c_id] == id && x[:locale] == 'en'}.first
      ka = shapes.select{|x| x[:c_id] == id && x[:locale] == 'ka'}.first

      if en.present? && ka.present?
puts "adding shape #{en[:c_name]}"
        u = UniqueShapeName.create(:shape_type_id => en[:shape_type_id])
        u.unique_shape_name_translations.create(:locale => 'ka', :common_id => ka[:c_id], :common_name => ka[:c_name]) 
        u.unique_shape_name_translations.create(:locale => 'en', :common_id => en[:c_id], :common_name => en[:c_name]) 
      end
    end

    
  end

  def down
    UniqueShapeName.delete_all
    UniqueShapeNameTranslation.delete_all
  end
end
