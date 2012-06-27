class JsonController < ApplicationController


	################################################3
	##### shape jsons
	################################################3
  # GET /json/shape/:id
  def shape
		geometries = Rails.cache.fetch("parent_shape_json_#{I18n.locale}_shape_#{params[:id]}") {
			#get the parent shape
			shape = Shape.where(:id => params[:id])
			Shape.build_json(shape)
		}

    respond_to do |format|
      format.json { render json: geometries }
    end
  end

  # GET /json/children_shapes/:parent_id(/parent_clickable/:parent_shape_clickable(/indicator/:indicator_id))
  def children_shapes
		geometries = nil
		# get parent of parent shape and see if grandchildren cache already exists
		shape = Shape.where(:id => params[:parent_id])
		parent_shape = nil
		if !shape.nil? && !shape.empty?
			parent_shape = shape.first.parent

			grandchildren_cache = nil
			if !parent_shape.nil?
				key = "grandchildren_shapes_json_#{I18n.locale}_shape_#{parent_shape.id}_indicator_#{params[:indicator_id]}"
logger.debug "++++++++++grand children key = #{key}"
				grandchildren_cache = Rails.cache.read(key)
			end

			if !grandchildren_cache.nil?
				# cache exists, pull out need shapes
logger.debug "++++++++++grand children cache exists, pulling out desired shapes"
#TODO - delete the below cache call and replace with code
# pulling shapes out of grand children cache
				geometries = Rails.cache.fetch("children_shapes_json_#{I18n.locale}_shape_#{params[:parent_id]}_parent_clickable_#{params[:parent_shape_clickable]}_indicator_#{params[:indicator_id]}") {
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

			else
logger.debug "++++++++++grand children cache does NOT exist"
				# no cache exists
				geometries = Rails.cache.fetch("children_shapes_json_#{I18n.locale}_shape_#{params[:parent_id]}_parent_clickable_#{params[:parent_shape_clickable]}_indicator_#{params[:indicator_id]}") {
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
			end
		end

    respond_to do |format|
      format.json { render json: geometries}
    end
  end

  # GET /json/grandchildren_shapes/:parent_id/indicator/:indicator_id
  def grandchildren_shapes
		key = "grandchildren_shapes_json_#{I18n.locale}_shape_#{params[:parent_id]}_indicator_#{params[:indicator_id]}"
		geometries = Rails.cache.fetch(key) {
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

logger.debug "++++++++++grand children key = #{key}"
    respond_to do |format|
      format.json { render json: geometries}
    end
  end

	################################################3
	##### summary shape jsons
	################################################3
  # GET /json/summary_children_shapes/:parent_id/event/:event_id/indicator_type/:indicator_type_id(/parent_clickable/:parent_shape_clickable)
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

    respond_to do |format|
      format.json { render json: geometries}
    end
  end


	################################################3
	##### summary data jsons
	################################################3
  # GET /json/summary_data/shape/:shape_id/event/:event_id/indicator_type/:indicator_type_id(/parent_clickable/:parent_shape_clickable)
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
