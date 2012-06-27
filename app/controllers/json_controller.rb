class JsonController < ApplicationController


  # GET /shape/:id
  def shape
		geometries = Rails.cache.fetch("shape_json_#{I18n.locale}_#{params[:id]}") {
			#get the parent shape
			shape = Shape.where(:id => params[:id])
			Shape.build_json(shape)
		}
=begin
    #get the parent shape
    shape = Shape.where(:id => params[:id])
    geometries = Shape.build_json(shape)
=end
    respond_to do |format|
      format.json { render json: geometries }
    end
  end

  # GET /children_shapes/:parent_id(/parent_clickable/:parent_shape_clickable(/indicator/:indicator_id))
  def children_shapes
    decoded = ActiveSupport::JSON.decode(Rails.cache.fetch("grandchildren_shapes_json_123"))
    needed = []
    decoded['features'].each do |value|
      if value['properties']['parent_id'] == params[:parent_id]
        needed << value
      end
    end
    decoded['features'] = needed

    respond_to do |format|
      format.json { render json: decoded}
    end


		geometries = Rails.cache.fetch("children_shapes_json_#{I18n.locale}_#{params[:parent_id]}_#{params[:parent_shape_clickable]}_#{params[:indicator_id]}") {
			geo = ''
			#get the parent shape
			shape = Shape.where(:id => params[:parent_id])

			if !shape.nil? && !shape.empty?
		    if !params[:parent_shape_clickable].nil? && params[:parent_shape_clickable].to_s == "true"
					# get the parent shape and format for json
					geo = Shape.build_json(shape, params[:indicator_id])
				elsif shape.first.has_children?
					# get all of the children of the parent and format for json
					geo = Shape.build_json(shape.first.children, params[:indicator_id])
				end
			end

			geo
		}
=begin
    geometries = nil
    #get the parent shape
    shape = Shape.where(:id => params[:parent_id])

    if !shape.nil? && shape.length > 0
      if !params[:parent_shape_clickable].nil? && params[:parent_shape_clickable].to_s == "true"
    		# get the parent shape and format for json
    		geometries = Shape.build_json(shape, params[:indicator_id])
    	elsif shape.first.has_children?
    		# get all of the children of the parent and format for json
    		geometries = Shape.build_json(shape.first.children, params[:indicator_id])
    	end
    end
=end
    #respond_to do |format|
    #  format.json { render json: geometries}
    #end
  end

  # GET /summary_children_shapes/:parent_id/event/:event_id/indicator_type/:indicator_type_id(/parent_clickable/:parent_shape_clickable)
  def summary_children_shapes
		geometries = Rails.cache.fetch("summary_children_shapes_json_#{I18n.locale}_#{params[:parent_id]}_event_#{params[:event_id]}_ind_type_#{params[:indicator_type_id]}_parent_clickable_#{params[:parent_shape_clickable]}") {
			geo = ''
			#get the parent shape
			shape = Shape.where(:id => params[:parent_id])

			if !shape.nil? && !shape.empty?
		    if !params[:parent_shape_clickable].nil? && params[:parent_shape_clickable].to_s == "true"
					# get the parent shape and format for json
					geo = Shape.build_summary_json(shape, params[:event_id], params[:indicator_type_id])
				elsif shape.first.has_children?
					# get all of the children of the parent and format for json
					geo = Shape.build_summary_json(shape.first.children, params[:event_id], params[:indicator_type_id])
				end
			end

			geo
		}
=begin
    geometries = nil
    #get the parent shape
    shape = Shape.where(:id => params[:parent_id])

		if !shape.nil? && !shape.empty?
	    if !params[:parent_shape_clickable].nil? && params[:parent_shape_clickable].to_s == "true"
				# get the parent shape and format for json
				geo = Shape.build_summary_json(shape, params[:event_id], params[:indicator_type_id])
			elsif shape.first.has_children?
				# get all of the children of the parent and format for json
				geo = Shape.build_summary_json(shape.first.children, params[:event_id], params[:indicator_type_id])
			end
		end
=end
    respond_to do |format|
      format.json { render json: geometries}
    end
  end

  # GET /grandchildren_shapes/:parent_id
  def grandchildren_shapes

   #geometries = Rails.cache.fetch("grandchildren_shapes_json_#{I18n.locale}_#{params[:parent_id]}_#{params[:parent_shape_clickable]}_#{params[:indicator_id]}") {
		geometries = Rails.cache.fetch("grandchildren_shapes_json_123") {
			geo = ''
			#get the parent shape
			shape = Shape.where(:id => params[:parent_id])

		  if !shape.nil? && shape.length > 0
		    if !params[:parent_shape_clickable].nil? && params[:parent_shape_clickable].to_s == "true"
		  		# get the parent shape and format for json
		  		geo = Shape.build_json(shape, params[:indicator_id])
		  	elsif shape.first.has_children?
		  		# get all of the grandchildren of the parent, and format for json
					shapes = [] 
					shape.first.children.each do |child|
						if child.has_children?
							shapes << child.children
						end
					end
					# flatten all of the nested arrays into just one array
					shapes.flatten!
		  		geo = Shape.build_json(shapes, params[:indicator_id])
		  	end
		  end

			geo
		}

=begin
    geometries = nil
    #get the parent shape
    shape = Shape.where(:id => params[:parent_id])

    if !shape.nil? && shape.length > 0
      if !params[:parent_shape_clickable].nil? && params[:parent_shape_clickable].to_s == "true"
    		# get the parent shape and format for json
    		geometries = Shape.build_json(shape, params[:indicator_id])
    	elsif shape.first.has_children?
    		# get all of the grandchildren of the parent, and format for json
				shapes = []
				shape.first.children.each do |child|
					if child.has_children?
						shapes << child.children
					end
				end
				# flatten all of the nested arrays into just one array
				shapes.flatten!
    		geometries = Shape.build_json(shapes, params[:indicator_id])
    	end
    end
=end
    respond_to do |format|
      format.json { render json: geometries}
    end
  end

  # GET /summary_data/shape/:shape_id/event/:event_id/indicator_type/:indicator_type_id(/parent_clickable/:parent_shape_clickable)
  def summary_data
		if !params[:shape_id].nil? && !params[:event_id].nil? && !params[:indicator_type_id].nil?
  		data = Rails.cache.fetch("summary_data_json_#{I18n.locale}_shape_#{params[:shape_id]}_event_#{params[:event_id]}_ind_type_#{params[:indicator_type_id]}_limit_#{params[:limit]}") {
  			d = ''
				# get all of the summary data and format for json
				if params[:limit].nil?
				  d = Datum.build_summary_json(params[:shape_id], params[:event_id], params[:indicator_type_id])
        else
				  d = Datum.build_summary_json(params[:shape_id], params[:event_id], params[:indicator_type_id], params[:limit])
        end

  			d
  		}
    end
    respond_to do |format|
      format.json { render json: data}
    end
  end

end
