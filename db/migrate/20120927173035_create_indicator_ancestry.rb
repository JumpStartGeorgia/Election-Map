class CreateIndicatorAncestry < ActiveRecord::Migration
  def up
    Event.all.each do |event|
      # core ind ids mapping non-precinct to precinct
      vpm_id_mapping = [[7,2], [8,3], [9,4], [10,5], [11,6]]
      vpm_id_parents = vpm_id_mapping.map{|x| x[0]}
      vpm_id_children = vpm_id_mapping.map{|x| x[1]}
      core_indicator_id = nil
      indicators = Indicator.where(:event_id => event.id).order("core_indicator_id, shape_type_id")
      shape_types = ShapeType.all
    
      indicators.each do |indicator|
        # do not need to process root shape type
        if indicator.shape_type_id != 1        
          parent_indicator = nil
          # if current indicator is a precinct vpm indicator, 
          # use the non-precinct core indicator id when looking for parent
          index = vpm_id_children.index(indicator.core_indicator_id)
          if index.nil?
            parent_indicator = indicators.select{|x| x.shape_type_id == indicator.shape_type.parent_id && 
                x.core_indicator_id == indicator.core_indicator_id}.first
          else
            parent_indicator = indicators.select{|x| x.shape_type_id == indicator.shape_type.parent_id && 
                x.core_indicator_id == vpm_id_parents[index]}.first
          end

          if parent_indicator
            indicator.parent_id = parent_indicator.id
            indicator.save
          end
        end
      end
    end
  end

  def down
    # delete all ancestry values
    connection = ActiveRecord::Base.connection()
    connection.execute("update indicators set ancestry = null")          
  end
end
