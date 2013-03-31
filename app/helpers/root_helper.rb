module RootHelper

	# look through the current shape and its ancestry/children 
	# for the provided shape_type_id 
	# returns the id of the parent shape because the root#index expects the parent shape id
  def get_shape_id(shape_type_id, use_ancestor_id = false)
logger.debug "############################ get_shape_id: start"
		if shape_type_id.nil?
logger.debug "get_shape_id: shape type id not provided"
			return nil
		else
logger.debug "get_shape_id: shape type id = #{shape_type_id}"
		  if shape_type_id.to_s == @shape.shape_type_id.to_s
		    # the current shape type matches
logger.debug "get_shape_id: current shape type matches"
		    return @shape.parent_id
		  end
		  
		  # see if shape has ancestors
logger.debug "get_shape_id: looking for ancestors"
		  if !@shape.ancestors.nil? && @shape.ancestors.length > 0
logger.debug "get_shape_id: found ancenstors, searching for match"
		    @shape.ancestors.each do |ancestor|
		      if shape_type_id.to_s == ancestor.shape_type_id.to_s
		        # found match in ancestor
						# if ancestor is root, use ancestor id, else parent_id
						if ancestor.parent_id.nil? || use_ancestor_id
logger.debug "get_shape_id: found match with root ancestor shape #{ancestor.id}"
			        return ancestor.id
            else
logger.debug "get_shape_id: found match with ancestor shape #{ancestor.parent_id}"
			        return ancestor.parent_id
						end
		      end
		    end
		  end

		  # see if shape has children
logger.debug "get_shape_id: looking for children"
		  if @shape.has_children? 
logger.debug "get_shape_id: found children, searching for match"
		    @shape.children.each do |child|
		      if shape_type_id.to_s == child.shape_type_id.to_s
		        # found match in child
logger.debug "get_shape_id: found match with child shape #{@shape.id}"
		        return @shape.id
		      end
		    end
		  end

logger.debug "get_shape_id: no matches found"
			return nil
	  end
  end

end
