class JsonController < ApplicationController


	################################################3
	##### shape jsons
	################################################3
  # GET /json/shape/:id
  def shape
		geometries = Rails.cache.fetch("parent_shape_json_#{I18n.locale}_shape_#{params[:id]}") {
			#get the parent shape
			shape = Shape.where(:id => params[:id])
			Shape.build_json(shape).to_json
		}

    respond_to do |format|
      format.json { render json: geometries }
    end
  end

  # GET /json/children_shapes/:parent_id(/parent_clickable/:parent_shape_clickable(/indicator/:indicator_id))
  def children_shapes
    start = Time.now
		geometries = nil
		# get parent of parent shape and see if grandchildren cache already exists
		shape = Shape.where(:id => params[:parent_id])
		parent_shape = nil
		if !shape.nil? && !shape.empty?
			parent_shape = shape.first.parent

			grandchildren_cache = nil
			if !parent_shape.nil?
				key = key_grandchildren_shapes.gsub("[parent_shape_id]", parent_shape.id.to_s).gsub("[indicator_id]", params[:indicator_id])
logger.debug "++++++++++grand children key = #{key}"
				grandchildren_cache = Rails.cache.read(key)
			end

			if !grandchildren_cache.nil?
				# cache exists, pull out need shapes
logger.debug "++++++++++grand children cache exists, pulling out desired shapes"

        geometries = ActiveSupport::JSON.decode(grandchildren_cache)
        needed = []
        geometries['features'].each do |value|
          if value['properties']['parent_id'] == params[:parent_id]
            needed << value
          end
        end
        geometries['features'] = needed
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

					geo.to_json
				}
			end
		end

    respond_to do |format|
      format.json { render json: geometries}
    end
    puts "@ time to render children_shapes json: #{Time.now-start} seconds"    
  end

  # GET /json/grandchildren_shapes/:parent_id/indicator/:indicator_id
  def grandchildren_shapes
    start = Time.now
		key = key_grandchildren_shapes.gsub("[parent_shape_id]", params[:parent_id]).gsub("[indicator_id]", params[:indicator_id])
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

			geo.to_json
		}

logger.debug "++++++++++grand children key = #{key}"
    respond_to do |format|
      format.json { render json: geometries}
    end
puts "@ time to render grandchildren_shapes json: #{Time.now-start} seconds"    
  end

	################################################3
	##### summary shape jsons
	################################################3
  # GET /json/summary_children_shapes/:parent_id/event/:event_id/indicator_type/:indicator_type_id(/parent_clickable/:parent_shape_clickable)
  def summary_children_shapes
    start = Time.now
		geometries = nil
		# get parent of parent shape and see if grandchildren cache already exists
		shape = Shape.where(:id => params[:parent_id])
		parent_shape = nil
		if !shape.nil? && !shape.empty?
			parent_shape = shape.first.parent

			grandchildren_cache = nil
			if !parent_shape.nil?
			key = key_summary_grandchildren_shapes.gsub("[parent_shape_id]", parent_shape.id.to_s).gsub("[event_id]", params[:event_id]).gsub("[indicator_type_id]", params[:indicator_type_id])
logger.debug "++++++++++grand children key = #{key}"
				grandchildren_cache = Rails.cache.read(key)
			end

			if !grandchildren_cache.nil?
				# cache exists, pull out need shapes
logger.debug "++++++++++grand children cache exists, pulling out desired shapes"

        geometries = ActiveSupport::JSON.decode(grandchildren_cache)
        needed = []
        geometries['features'].each do |value|
          if value['properties']['parent_id'] == params[:parent_id]
            needed << value
          end
        end
        geometries['features'] = needed
			else
logger.debug "++++++++++grand children cache does NOT exist"
				# no cache exists
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

					geo.to_json
				}
			end
		end

    respond_to do |format|
      format.json { render json: geometries}
    end
    puts "@ time to render summary_children_shapes json: #{Time.now-start} seconds"    
  end


  # GET /summary_grandchildren_shapes/:parent_id/event/:event_id/indicator_type/:indicator_type_id
  def summary_grandchildren_shapes
    start = Time.now
		key = key_summary_grandchildren_shapes.gsub("[parent_shape_id]", params[:parent_id]).gsub("[event_id]", params[:event_id]).gsub("[indicator_type_id]", params[:indicator_type_id])
		geometries = Rails.cache.fetch(key) {
			geo = ''
			#get the parent shape
			shape = Shape.where(:id => params[:parent_id])

			if !shape.nil? && !shape.empty?
		    if !params[:parent_shape_clickable].nil? && params[:parent_shape_clickable].to_s == "true"
					# get the parent shape and format for json
					geo = Shape.build_summary_json(shape, params[:event_id], params[:indicator_type_id])
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
					geo = Shape.build_summary_json(shapes, params[:event_id], params[:indicator_type_id])
				end
			end

			geo.to_json
		}

    respond_to do |format|
      format.json { render json: geometries}
    end
    puts "@ time to render summary_grandchildren_shapes json: #{Time.now-start} seconds"    
  end


	################################################3
	##### summary data jsons
	################################################3
  # GET /json/summary_data/shape/:shape_id/event/:event_id/indicator_type/:indicator_type_id(/limit/:limit)
  def summary_data
		if !params[:shape_id].nil? && !params[:event_id].nil? && !params[:indicator_type_id].nil?
  		data = Rails.cache.fetch("summary_data_json_#{I18n.locale}_shape_#{params[:shape_id]}_event_#{params[:event_id]}_ind_type_#{params[:indicator_type_id]}_limit_#{params[:limit]}") {

				# get all of the summary data and format for json
			  Datum.build_summary_json(params[:shape_id], params[:event_id], params[:indicator_type_id], params[:limit]).to_json
  		}
    end
    respond_to do |format|
      format.json { render json: data}
    end
  end

protected

	def key_grandchildren_shapes
		"grandchildren_shapes_json_#{I18n.locale}_shape_[parent_shape_id]_indicator_[indicator_id]}"
	end

	def key_summary_grandchildren_shapes
		"summary_grandchildren_shapes_json_#{I18n.locale}_shape_[parent_shape_id]_event_[event_id]_ind_type_[indicator_type_id]"
	end

end
