module RootHelper

	# look through the current shape and its ancestry/children 
	# for the provided shape_type_id 
	# returns the id of the parent shape because the root#index expects the parent shape id
  def get_shape_id(shape_type_id)
    if shape_type_id.to_s == @shape.shape_type_id.to_s
      # the current shape type matches
      return @shape.parent_id
    end
    
    # see if shape has ancestors
    if !@shape.ancestors.nil? && @shape.ancestors.length > 0
      @shape.ancestors.each do |ancestor|
        if shape_type_id.to_s == ancestor.shape_type_id.to_s
          # found match in ancestor
          return ancestor.parent_id
        end
      end
    end

    # see if shape has children
    if @shape.has_children? 
      @shape.children.each do |child|
        if shape_type_id.to_s == child.shape_type_id.to_s
          # found match in child
          return @shape.id
        end
      end
    end

		return nil
  end

end
