class Shape < ActiveRecord::Base
  translates :common_id, :common_name
  has_ancestry

  has_many :shape_translations, :dependent => :destroy
  belongs_to :shape_type
  accepts_nested_attributes_for :shape_translations
  attr_accessible :shape_type_id, :num_precincts, :geometry, :shape_translations_attributes
  attr_accessor :locale

  validates :shape_type_id, :geometry, :presence => true

	# get the name of the shape (common_id)
	def self.get_shape_name(shape_id)
		return shape_id.nil? ? "" : select("common_id")
				.joins(:shape_translations)
				.where(:shapes => {:id => shape_id}, :shape_translations => {:locale => I18n.locale}).first
	end

	# get the name of the shape (common_id)
	def self.get_shape_no_geometry(shape_id)
		return shape_id.nil? ? "" : select("shapes.id, shapes.shape_type_id, shape_translations.common_id, shape_translations.common_name, shapes.ancestry, shapes.num_precincts")
					.joins(:shape_translations)
					.where(:shapes => {:id => shape_id}, :shape_translations => {:locale => I18n.locale}).first
	end

	# get the list of shapes for data download
	def self.get_shapes_by_type(shape_id, shape_type_id, includeGeoData = false)
		if !shape_id.nil? && !shape_type_id.nil?
		  if includeGeoData
			  Shape.find(shape_id).subtree.where(:shape_type_id => shape_type_id).with_translations(I18n.locale)
			else
			  Shape.find(shape_id).subtree.select("shapes.id, shape_translations.common_id as shape_common_id, shape_translations.common_name as shape_common_name")
				.joins(:shape_translations)
				.where(:shapes => {:shape_type_id => shape_type_id}, :shape_translations => {:locale => I18n.locale})
		  end
		end
	end

	# create the properly formatted json string
	def self.build_json(shape_id, shape_type_id, event_id=nil, data_set_id=nil, indicator_id=nil, data_type=nil)
    json = Hash.new()
		start = Time.now
		if !shape_id.nil? && !shape_type_id.nil?
		  shapes = get_shapes_by_type(shape_id, shape_type_id, true)

      json["type"] = "FeatureCollection"
      json["features"] = Array.new(shapes.length) {Hash.new}

			shapes.each_with_index do |shape, i|
				json["features"][i]["type"] = "Feature"
				# have to parse it for the geo is already in json format and
				# transforming it to json again escapes the "" and breaks openlayers
				json["features"][i]["geometry"] = JSON.parse(shape.geometry)
				json["features"][i]["properties"] = build_json_properties_for_shape(shape, indicator_id, event_id, data_set_id, data_type)
			end
		end
		if indicator_id.nil?
#			puts "+++ time to build json: #{Time.now-start} seconds with no indicator"
		else
#			puts "+++ time to build json: #{Time.now-start} seconds for indicator #{indicator_id}"
		end
		return json
	end

	# create the properly formatted json string
	def self.build_summary_json(shape_id, shape_type_id, event_id, data_set_id, indicator_type_id, data_type)
		start = Time.now
    json = Hash.new()
		if shape_id && shape_type_id && event_id && indicator_type_id && data_type
		  shapes = get_shapes_by_type(shape_id, shape_type_id, true)

      json["type"] = "FeatureCollection"
      json["features"] = Array.new(shapes.length) {Hash.new}

			shapes.each_with_index do |shape, i|


				json["features"][i]["type"] = "Feature"
				# have to parse it for the geo is already in json format and
				# transforming it to json again escapes the "" and breaks openlayers

				json["features"][i]["geometry"] = JSON.parse(shape.geometry) if shape.geometry
				json["features"][i]["properties"] = build_json_properties_for_shape(shape, indicator_type_id, event_id, data_set_id, data_type, true)

			end
		end
#		puts "+++ time to build summary json: #{Time.now-start} seconds for event #{event_id} and indicator type #{indicator_type_id}"
		return json
	end

  def self.build_json_properties_for_shape(shape, ind_id, event_id, data_set_id, data_type, isSummary = false)
    start = Time.now
    properties = Hash.new
    if !shape.nil?
			properties["id"] = shape.id
			properties["parent_id"] = shape.parent_id
			properties["common_id"] = shape.common_id
			properties["common_name"] = shape.common_name
			properties["has_children"] = shape.has_children?
			properties["shape_type_id"] = shape.shape_type_id
			properties["shape_type_name"] = shape.shape_type.name_singular
      # pre-load data properties as if no data found
		  properties["data_value"] = I18n.t('app.msgs.no_data')
		  properties["value"] = I18n.t('app.msgs.no_data')
		  properties["formatted_value"] = I18n.t('app.msgs.no_data')
		  properties["color"] = nil
		  properties["number_format"] = nil
			properties["results"] = Array.new
			title = Hash.new
			title["location"] = "#{shape.shape_type.name_singular}: #{shape.common_name}"
			title["title"] = I18n.t('app.msgs.no_data')
			title["title_abbrv"] = ""
			title["precincts_completed"] = nil

      if ind_id && data_set_id
        # get the data for the provided base shape and using the ancestry path to this shape
        if isSummary
  			  data = Datum.get_related_indicator_type_data(shape.id, shape.shape_type_id, event_id, ind_id, data_set_id)
        else
    			data = Datum.get_related_indicator_data(shape.id, ind_id, data_set_id)
        end

  			# look for data
  			results = []
  			if !data.nil? && !data.empty?
    			results = Array.new(data.length) {Hash.new}
    			data.each_with_index do |d,i|
    			  if d.has_key?("summary_data") && !d["summary_data"].nil? && !d["summary_data"].empty?
  			      results[i]["summary_data"] = d["summary_data"]
  			      # if getting summary data, use the first record for the shape value
							# unless the first value is 'no data'
  			      # if ind_id = indicator_type_id
  			      if isSummary && d["summary_data"][0][:indicator_type_id].to_s == ind_id.to_s &&
									d["summary_data"][0][:formatted_value] != I18n.t('app.msgs.no_data')

      				  properties["data_value"] = d["summary_data"][0][:formatted_value] if !d["summary_data"][0][:formatted_value].nil?
      					properties["value"] = d["summary_data"][0][:indicator_name_abbrv]
      					properties["formatted_value"] = d["summary_data"][0][:indicator_name]
      				  properties["number_format"] = d["summary_data"][0][:number_format]
      				  properties["color"] = d["summary_data"][0][:color]
								# set the title hash
								title["title"] = d["summary_data"][0][:indicator_type_name]
  		        end
    		    elsif d.has_key?("data_item") && !d["data_item"].nil? && !d["data_item"].empty?
  		        results[i]["data_item"] = d["data_item"]
  			      # if not getting summary data, use this record
  			      # if ind_id = indicator_id
  			      if !isSummary && d["data_item"][:indicator_id].to_s == ind_id.to_s
      				  properties["data_value"] = nil
      					properties["value"] = d["data_item"][:value] if !d["data_item"][:value].nil?
      					properties["formatted_value"] = d["data_item"][:formatted_value] if !d["data_item"][:formatted_value].nil?
      				  properties["number_format"] = d["data_item"][:number_format]
								# set the title hash
								title["title"] = d["data_item"][:indicator_name]
								title["title_abbrv"] = d["data_item"][:indicator_name_abbrv]
  		        end
    		    elsif d.has_key?("footnote") && !d["footnote"].nil? && !d["footnote"].empty?
  		        results[i]["footnote"] = d["footnote"]
    	      end
    		  end

					# if this is live data and not a precinct, add the precincts reported numbers
					if data_type == Datum::DATA_TYPE[:live] && !shape.shape_type.is_precinct?
						precincts_reporting = Datum.get_precincts_reported(shape.id, event_id, data_set_id)
						if precincts_reporting && !precincts_reporting.empty?
							title["precincts_completed"] =
										I18n.t('app.common.live_event_status', :completed => precincts_reporting[:completed_number],
                        :total => precincts_reporting[:num_precincts],
                        :percentage => precincts_reporting[:completed_percent])
						end
					end


					# add title to the results
					results.insert(0, Hash.new)
					results[0]["title"] = title
				else
					# there is no data, so just add title
					results = Array.new(1) {Hash.new}
					results[0]["title"] = title
				end
        properties["results"] = results
      end
    end
#		puts "++++++ time to build json properties for shape #{shape.id}: #{Time.now-start} seconds"
#		puts "+++++++++++++++++++++++++"
		return properties
  end


  def self.csv_header
    "Event, Shape Type, Parent ID, Parent Name, Common ID, Common Name, Geometry".split(",")
  end

    def self.build_from_csv(file, deleteExistingRecord)
      start = Time.now
	    infile = file.read
	    n, msg = 0, ""
			root = nil
			old_root_id = nil
      idx_event = 0
      idx_shape_type = 1
      idx_parent_id = 2
      idx_parent_name = 3
      idx_common_id = 4
      idx_common_name = 5
      idx_geo = 6


			Shape.transaction do
			  CSV.parse(infile, :col_sep => "\t") do |row|
          startRow = Time.now
			    n += 1
			    # SKIP: header i.e. first row OR blank row
			    next if n == 1 or row.join.blank?
    puts "++++processing row #{n}"

	        if row[idx_event].nil? || row[idx_event].strip.length == 0 || row[idx_shape_type].nil? || row[idx_shape_type].strip.length == 0
    logger.debug "++++event or shape type was not found in spreadsheet"
      		  msg = I18n.t('models.shape.msgs.no_event_shape_spreadsheet', :row_num => n)
			      raise ActiveRecord::Rollback
            return msg
					else
					  startPhase = Time.now
		    		# get the event id
		    		event = Event.find_by_name(row[idx_event].strip)
		    		# get the shape type id
		    		shape_type = ShapeType.find_by_name_singular(row[idx_shape_type].strip)
          	puts "**** time to load event and shape type: #{Time.now-startPhase} seconds"

		    		if event.nil? || shape_type.nil?
		  logger.debug "++++event or shape type was not found"
		    		  msg = I18n.t('models.shape.msgs.no_event_shape_db', :row_num => n)
					    raise ActiveRecord::Rollback
		          return msg
		    		else
		  logger.debug "++++found event and shape type, get root shape"
              startPhase = Time.now
		          # get the root shape
		          root = Shape.joins(:shape_translations)
		                  .where(:shapes => {:id => event.shape_id}, :shape_translations => {:locale => 'en'}).first
            	puts "**** time to get root shape: #{Time.now-startPhase} seconds"

		          # if the root shape already exists and deleteExistingRecord is true, delete the shape
							#  if this is the root record (row[idx_parent_id] is nil)
		          if !root.nil? && deleteExistingRecord && (row[idx_parent_id].nil? || row[idx_parent_id].strip.length == 0)
		logger.debug "+++++++ deleting existing root shape and all of its descendants"
									# save the existing root id so at the end all events with this root can be updated
									old_root_id = root.id
									# destroy the shapes
									ShapeTranslation.delete_all(["shape_id in (?)", root.subtree_ids])
		              Shape.delete_all(["id in (?)", root.subtree_ids])
		              root = nil
		          end

		          if root.nil?
		  logger.debug "++++root does not exist"
		            if row[idx_parent_id].nil? || row[idx_parent_id].strip.length == 0
		              # no root exists in db, but this is the root, so add it
                  startPhase = Time.now
		  logger.debug "++++adding root shape"
                  shape = Shape.create :shape_type_id => shape_type.id, :geometry => row[idx_geo].strip
									# add translations
									I18n.available_locales.each do |locale|
										shape.shape_translations.create(:locale => locale, :common_id => row[idx_common_id].strip, :common_name => row[idx_common_name].strip)
									end
                  puts "******** time to create root shape: #{Time.now-startPhase} seconds"

		              if shape.valid?
                    startPhase = Time.now
		                # update the event to have this as the root
		  logger.debug "++++updating event to map to this root shape"

										events = Event.where(:shape_id => old_root_id)
										if !events.nil? && !events.empty?
		  logger.debug "+++++++there are #{events.count} that have this old root id"
											events.each do |e|
												e.shape_id = shape.id
						            if !e.save
						              # could not update event record
						        		  msg = I18n.t('models.shape.msgs.not_update_event', :row_num => n)
					logger.debug "++++event could not be updated to indicate this is the root"
						  			      raise ActiveRecord::Rollback
						        		  return msg
						            end
											end
										end
										puts "******** time to update shape_id for events: #{Time.now-startPhase} seconds"
		              else
		                # could not create shape
		          		  msg = I18n.t('models.shape.msgs.root_not_valid', :row_num => n)
		  logger.debug "++++root row could not be saved"
		    			      raise ActiveRecord::Rollback
		          		  return msg
		              end
		            else
		              # no root exists and this row is not root -> stop
		        		  msg = I18n.t('models.shape.msgs.root_shape_not_found', :row_num => n)
		    logger.debug "++++root shape for this event was not found"
		              raise ActiveRecord::Rollback
		              return msg
		            end
		          elsif n == 2
		    logger.debug "++++ this is the first row and root already exists"
		      		  msg = I18n.t('models.shape.msgs.root_already_exists', :row_num => n)
		            raise ActiveRecord::Rollback
		            return msg
		          else
		    logger.debug "++++root already exists"
		            # found root, continue
	              # only conintue if all values are present
	              if row[idx_parent_id].nil? || row[idx_parent_name].nil? || row[idx_common_id].nil? || row[idx_common_name].nil? || row[idx_geo].nil?
	          		  msg = I18n.t('models.shape.msgs.missing_data_spreadsheet', :row_num => n)
	    logger.debug "++++**missing data in row"
	                raise ActiveRecord::Rollback
	                return msg
			          else
			            # if this is row 2, see if this row is also a root and the same
				          if n==2 && row[idx_parent_id].nil? && root.shape_type_id == shape_type.id &&
											root.common_id == row[idx_common_id].strip && root.common_name == row[idx_common_name].strip
				      		  msg = I18n.t('models.shape.msgs.root_already_exists', :row_num => n)
				  logger.debug "++++**root record already exists!"
				            raise ActiveRecord::Rollback
				            return msg
		              else
                    startPhase = Time.now
		    logger.debug "++++chekcing if row already in db"
		                alreadyExists = root.descendants.select("shapes.id").joins(:shape_translations)
		                  .where(:shapes => {:shape_type_id => shape_type.id, :geometry => row[idx_geo].strip},
		                    :shape_translations => {:locale => 'en', :common_id => row[idx_common_id].strip, :common_name => row[idx_common_name].strip})
                  	puts "**** time to get existing shape: #{Time.now-startPhase} seconds"

		                # if the shape already exists and deleteExistingRecord is true, delete the sha[e]
		                if !alreadyExists.nil? && alreadyExists.length > 0 && deleteExistingRecord
			logger.debug "+++++++ deleting existing #{alreadyExists.length} shape record and all of its descendants "
                        alreadyExists.each do |exists|
						              Shape.destroy_all(["id in (?)", exists.subtree_ids])
                        end
		                    alreadyExists = nil
		                end

		                if alreadyExists.nil? || alreadyExists.empty?
		    logger.debug "++++row is not in db, get parent shape type"
		                  # record does not exist yet
		                  # find parent shape type so we can find parent shape
		                  parent_shape_type = shape_type.parent
		                  if parent_shape_type.nil?
		                    # did not find parent shape type
		              		  msg = I18n.t('models.shape.msgs.parent_shape_type_not_found', :row_num => n)
		        logger.debug "++++**could not find parent shape type"
		                    raise ActiveRecord::Rollback
		                    return msg
		                  else
		      logger.debug "++++getting parent shape"
		                    startPhase = Time.now
		                    # check if the root has descendants
		                    # have to check the root object by iteself and then check for through the descendants
		                    parentRoot = root.shape_type_id == parent_shape_type.id &&
		                      root.common_id == row[idx_parent_id].strip && root.common_name == row[idx_parent_name].strip ? root : nil
		                    if root.has_children?
		                      parentChild = root.descendants.select("shapes.id, shapes.ancestry").joins(:shape_translations)
		                        .where(:shapes => {:shape_type_id => parent_shape_type.id},
		                        :shape_translations => {:locale => 'en', :common_id => row[idx_parent_id].strip, :common_name => row[idx_parent_name].strip})
		                    end

		                    # see if a parent node was found
		                    if (parentRoot.nil?) && (parentChild.nil? || parentChild.empty?)
		        logger.debug "++++no parent shape found"
		                      # no parent found
		                      parent = nil
		                    elsif !parentRoot.nil?
		        logger.debug "++++parent shape is root"
		                      parent = parentRoot
		                    elsif !parentChild.nil? && parentChild.length > 0
		        logger.debug "++++parent is a child node"
		                      parent = parentChild.first
		                    end
		        logger.debug "++++parent = #{parent}"
          	            puts "**** time to find parent shape: #{Time.now-startPhase} seconds"

		                    if parent.nil?
		                      # did not find parent shape
			              		  msg = I18n.t('models.shape.msgs.parent_shape_not_found', :row_num => n)
		          logger.debug "++++**could not find parent shape"
		                      raise ActiveRecord::Rollback
		                      return msg
		                    else
		                      # found parent, add child
		      logger.debug "++++found parent, saving this row"
													#################################
													# HACK
													# if this is the district Khobi, use the geo that is provided at the bottom of this class
													# - the khobi district geo that has something bad in it and the string gets cut off
													#################################
													startPhase = Time.now
													if row[idx_common_name].strip.downcase == "khobi"
          logger.debug "++++++++++++++ found khobi, using geo data hardcoded into app"
			                      shape = parent.children.create :shape_type_id => shape_type.id, :geometry => khobi_district_geometry
													else
			                      shape = parent.children.create :shape_type_id => shape_type.id, :geometry => row[idx_geo].strip
													end
													# add translations
													I18n.available_locales.each do |locale|
														shape.shape_translations.create(:locale => locale, :common_id => row[idx_common_id].strip, :common_name => row[idx_common_name].strip)
													end
                        	puts "************ time to create shape record: #{Time.now-startPhase} seconds"

		                      if !shape.valid?
		                        # could not create shape
		                  		  msg =I18n.t('models.shape.msgs.not_valid', :row_num => n)
		          logger.debug "++++row could not be saved"
		                        raise ActiveRecord::Rollback
		                        return msg
		                      end
		                    end
		                  end
		                else
		                  # record already exists
		            		  msg = I18n.t('models.shape.msgs.already_exists', :row_num => n)
		          logger.debug "++++**record already exists!"
		                  raise ActiveRecord::Rollback
		                  return msg
		                end
		              end
		            end
		          end
		        end
	        end
          puts "************ time to process row: #{Time.now-startRow} seconds"
        end

			  logger.debug "++++updating ka records with ka text in shape_names"
        startPhase = Time.now
				# ka translation is hardcoded as en in the code above
				# update all ka records with the apropriate ka translation
				# update common ids
				ActiveRecord::Base.connection.execute("update shape_translations as st, shape_names as sn set st.common_id = sn.ka where st.locale = 'ka' and st.common_id = sn.en")
				# update common names
				ActiveRecord::Base.connection.execute("update shape_translations as st, shape_names as sn set st.common_name = sn.ka where st.locale = 'ka' and st.common_name = sn.en")
#      	puts "************ time to update 'ka' common id and common name: #{Time.now-startPhase} seconds"

			  logger.debug "++++add precinct counts"
				# add precinct counts to each new shape file
				add_precinct_count(root.id) if root

			end
		  logger.debug "++++procssed #{n} rows in CSV file"
#	    puts "****************** time to build_from_csv: #{Time.now-start} seconds"
      return msg
    end


		# delete all shapes that are assigned to the
		# provided event_id at the given shape_type_id
		# and all of the shape_types children
		def self.delete_shapes(event_id, shape_type_id)
			msg = nil
			if !event_id.nil? && !shape_type_id.nil?
				# get the event
				event = Event.find(event_id)
				if !event.nil? && !event.shape_id.nil? && !event.shape.nil?
					# get the shape type
					shape_type = ShapeType.find(shape_type_id)
					if !shape_type.nil?
						Shape.transaction do
							# if the event root shape was deleted, update events and remove the id
							if !shape_type.subtree_ids.index(event.shape.shape_type_id).nil?
								# get all events with this shape id
								events = Event.where(:shape_id => event.shape_id)
								if !events.nil? && !events.empty?
									events.each do |e|
										e.shape_id = nil
										if !e.save
											msg = "error occurred while updating event record"
						          raise ActiveRecord::Rollback
											return msg
										end
									end
								end
							end

							# delete the shapes
							shapes = Shape.select("id").where(["id in (:shape_ids) and shape_type_id in (:shape_type_ids)",
								:shape_ids => event.shape.subtree_ids, :shape_type_ids => shape_type.subtree_ids])
							error1 = ShapeTranslation.delete_all(["shape_id in (?)", shapes.collect(&:id)])
							error2 = Shape.delete_all(["id in (?)", shapes.collect(&:id)])
              logger.debug "############## - error1 = #{error1} | error2 = #{error2}"
		          if error1 == 0 || error2 == 0
								msg = "error occurred while deleting records"
                raise ActiveRecord::Rollback
								return msg
							end
						end
					else
						msg = "shape type could not be found"
						return msg
					end
				else
					msg = "event could not be found"
					return msg
				end
			else
				msg = "params not provided"
				return msg
			end
			return msg
		end

		#######################
		# compute number of precincts within each shape that belongs to the provided root shape
		#######################
		def self.add_precinct_count(root_id)
			start = Time.now
			shape = Shape.find(root_id)
			shape_types = ShapeType.precincts
			if shape && shape_types && !shape_types.empty?
				# get number for root
				shape.num_precincts = compute_number_precincts(shape.id, shape_types)
				shape.save

				# process each descendant that is not a precinct
				descendants = shape.descendants.where("shape_type_id not in (:ids)", :ids => shape_types.collect(&:id))
				descendants.each do |descendant|
					descendant.num_precincts = compute_number_precincts(descendant.id, shape_types)
					descendant.save
				end
			end
			logger.debug "************* time to add precincts count to shape set was #{Time.now - start} seconds"
		end

		# compute number of precincts that are a child of each shape and add to record
		def self.compute_number_precincts(shape_id, shape_types)
			number = nil
			if shape_types && !shape_types.empty?
				number = Shape.find(shape_id).descendants.where("shape_type_id in (:ids)", :ids => shape_types.collect(&:id)).length
			end
			return number
		end

		# update precinct count for all shapes
		def self.add_precinct_count_all_shapes
			start = Time.now
			shapes = Shape.where("ancestry is null")
			if shapes && !shapes.empty?
				shapes.each do |shape|
					add_precinct_count(shape.id)
				end
			end
			logger.debug "************* time to add precincts count to ALL shapes was #{Time.now - start} seconds"
		end


protected

def shape_common_id=(val)
	self[:shape_common_id] = val
end
def shape_common_id
	self[:shape_common_id]
end
def shape_common_name=(val)
	self[:shape_common_name] = val
end
def shape_common_name
	self[:shape_common_name]
end

	def self.khobi_district_geometry
"{\"type\":\"Polygon\", \"coordinates\":[[[4673562.917833, 5231866.42526], [4673574.244518, 5231866.829781], [4673630.072025, 5231891.588662], [4673640.592826, 5231914.729641], [4673732.81827, 5231872.491652], [4674009.489844, 5231745.773164], [4674009.489844, 5231745.773164], [4674132.875268, 5231784.320572], [4674495.730446, 5231785.868099], [4674564.494209, 5231765.551834], [4674655.910977, 5231746.041526], [4674758.25243, 5231738.301605], [4674926.14522, 5231801.187406], [4675024.875537, 5231895.759467], [4675047.529252, 5231896.564982], [4675092.435482, 5231909.544255], [4675149.069895, 5231911.557541], [4675216.63017, 5231925.341472], [4675272.061714, 5231961.459429], [4675428.931853, 5231693.850158], [4675436.145942, 5231489.224989], [4675562.739612, 5231436.809157], [4675564.342048, 5231391.337693], [4675565.54386, 5231357.234236], [4675576.870124, 5231357.6363], [4675600.724332, 5231324.337038], [4675760.492754, 5231295.860767], [4675806.197906, 5231286.100236], [4675943.712986, 5231245.449638], [4675966.365318, 5231246.252821], [4676001.143966, 5231224.722104], [4676218.739835, 5231164.142777], [4676229.266352, 5231187.279326], [4676576.782474, 5231302.021633], [4676725.621209, 5231261.760235], [4676652.284776, 5230121.042559], [4676852.631852, 5229581.876964], [4677447.690709, 5229102.191676], [4676995.777155, 5228733.481175], [4677047.846026, 5228541.881564], [4677866.082488, 5228809.708954], [4679624.938245, 5228439.135745], [4680233.503036, 5228870.086759], [4682383.617202, 5228000.648742], [4682682.005526, 5227237.337319], [4682381.502522, 5226419.155384], [4681892.471791, 5225810.606648], [4681539.187932, 5225866.558325], [4680812.924987, 5225238.347297], [4680532.520866, 5224500.597739], [4680899.532596, 5224047.095748], [4681135.638541, 5224100.826047], [4681106.796984, 5223951.967155], [4681100.591754, 5223803.9], [4681027.661203, 5223619.389247], [4681019.883844, 5223516.763075], [4681069.872884, 5223382.035253], [4681071.445966, 5223336.600058], [4681185.96353, 5222646.896546], [4681089.227437, 5222495.693187], [4680938.274353, 5222274.372377], [4680846.266946, 5221986.885954], [4680704.772651, 5221493.012584], [4680669.647013, 5221525.897262], [4680601.363354, 5221534.883424], [4680567.812042, 5221522.34145], [4680435.577009, 5221415.390233], [4680370.839357, 5221322.16724], [4680140.952298, 5220438.676474], [4680119.113265, 5220415.174861], [4680108.19379, 5220403.424059], [4680009.131199, 5220320.377132], [4680088.325779, 5220323.146784], [4680133.579859, 5220324.729145], [4680324.334413, 5220376.872404], [4680423.794252, 5220448.561356], [4680559.952341, 5220441.947799], [4680708.997769, 5220390.306095], [4680880.365276, 5220021.116788], [4681132.00693, 5219950.311946], [4681574.071262, 5219613.293973], [4681521.823491, 5219486.427494], [4681489.062791, 5219451.183323], [4681467.22246, 5219427.687224], [4681344.354544, 5219377.937229], [4681322.122142, 5219365.795069], [4681288.184681, 5219364.612861], [4681288.184681, 5219364.612861], [4681254.63992, 5219352.076468], [4681244.112847, 5219328.974248], [4681164.925817, 5219326.214943], [4681130.595709, 5219336.3862], [4680781.575382, 5218949.088452], [4680615.927089, 5218499.995451], [4680331.280255, 5218217.258747], [4680334.535046, 5217796.82572], [4680334.928688, 5217785.4736], [4680279.557244, 5217749.441728], [4680268.640494, 5217737.694511], [4680247.200813, 5217702.848074], [4680224.579996, 5217702.057673], [4680202.352977, 5217689.915224], [4680145.013323, 5217710.642845], [4679948.913897, 5217487.839877], [4679926.687749, 5217475.697085], [4679896.698765, 5217360.994007], [4679896.698765, 5217360.994007], [4679897.881137, 5217326.939359], [4679938.5101, 5217135.151881], [4679961.129514, 5217135.942865], [4679961.523542, 5217124.591563], [4679998.604481, 5217034.967966], [4680045.418531, 5216991.144868], [4680057.121977, 5216980.189086], [4680080.528786, 5216958.277512], [4680116.032623, 5216914.059062], [4680143.376991, 5216778.637797], [4679328.203301, 5216125.080868], [4679286.127447, 5216032.696252], [4679231.954583, 5215962.615812], [4679046.824786, 5215751.583042], [4678915.475802, 5215621.980306], [4678871.825335, 5215574.996292], [4678803.583592, 5215583.965554], [4678791.880554, 5215594.91819], [4678780.572789, 5215594.521444], [4678745.85882, 5215616.029885], [4678722.847879, 5215626.585663], [4678722.847879, 5215626.585663], [4678597.275633, 5215656.267995], [4678529.428731, 5215653.885884], [4678429.241367, 5215604.914293], [4678418.329354, 5215593.167769], [4678408.604589, 5215547.373345], [4678409.396062, 5215524.67481], [4678422.6823, 5215468.325885], [4678424.265144, 5215422.929239], [4678186.807392, 5215414.585814], [4678112.803935, 5215264.266284], [4678078.882011, 5215263.073655], [4678067.574706, 5215262.676084], [4678057.455794, 5215228.231831], [4678047.336951, 5215193.787694], [4678036.425881, 5215182.041273], [4678036.822029, 5215170.692466], [4678014.603822, 5215158.548439], [4678003.692833, 5215146.802026], [4678003.692833, 5215146.802026], [4677972.544899, 5215066.16802], [4677984.644361, 5215043.86837], [4677964.407615, 5214974.981424], [4677191.192372, 5214425.096411], [4677262.792822, 5214643.497462], [4677240.179839, 5214642.700466], [4677240.179839, 5214642.700466], [4676794.854464, 5214751.977485], [4676783.547886, 5214751.578423], [4676128.071395, 5215364.724042], [4676509.895914, 5215775.932591], [4676186.259044, 5216287.224956], [4676185.860582, 5216298.574914], [4676147.950389, 5216410.875343], [4676135.84483, 5216433.175565], [4676122.942105, 5216478.176138], [4676048.712342, 5216657.380097], [4675861.928366, 5217139.454352], [4675466.502011, 5217114.081361], [4675323.477325, 5216995.361163], [4675281.437734, 5216902.951734], [4675272.126783, 5216845.797845], [4675272.925991, 5216823.096814], [4675232.486159, 5216685.287433], [4675144.814513, 5216602.626207], [4675133.505886, 5216602.224995], [4675110.48886, 5216612.77276], [4675098.380639, 5216635.072004], [4675074.963674, 5216656.969995], [4675052.346304, 5216656.167379], [4675007.511487, 5216643.211715], [4674996.202824, 5216642.810334], [4674963.476708, 5216607.555398], [4674930.750835, 5216572.300489], [4674919.842264, 5216560.548859], [4674897.225153, 5216559.745889], [4674886.316639, 5216547.994237], [4674863.699565, 5216547.191189], [4674852.391029, 5216546.789645], [4674830.174069, 5216534.636391], [4674819.265669, 5216522.884697], [4674786.540632, 5216487.629635], [4674664.949756, 5216403.760984], [4674551.065514, 5216422.442574], [4674494.924236, 5216409.082956], [4674438.78313, 5216395.723029], [4674157.278393, 5216351.618402], [4674113.649227, 5216304.609607], [4673994.072313, 5216163.986058], [4673994.072313, 5216163.986058], [4673994.473381, 5216152.636465], [4673906.015408, 5216092.667981], [4673768.313987, 5216144.582897], [4673688.355479, 5216164.461988], [4673642.72212, 5216174.199807], [4673620.106168, 5216173.393846], [4673507.829797, 5216146.664134], [4673407.665535, 5216097.637477], [4672841.469349, 5216100.157296], [4672818.048785, 5216122.04828], [4672794.628114, 5216143.939252], [4672803.521028, 5216212.440261], [4672813.21903, 5216258.242529], [4672831.810338, 5216372.547155], [4672741.345284, 5216369.315059], [4672695.710154, 5216379.048413], [4671696.965939, 5216445.580258], [4671423.146539, 5216503.946875], [4671275.736217, 5216510.021906], [4671173.558411, 5216517.718574], [4671139.633953, 5216516.500633], [4671117.017656, 5216515.688604], [4670946.990883, 5216520.946396], [4670912.256907, 5216542.42713], [4670899.734341, 5216576.070179], [4670888.021324, 5216587.013681], [4670887.616504, 5216598.363497], [4670863.785507, 5216631.600368], [4670826.621533, 5216721.180552], [4670802.385064, 5216765.76768], [4670801.980124, 5216777.1177], [4670790.266742, 5216788.061295], [4670789.051868, 5216822.111471], [4670777.743388, 5216821.705014], [4670766.029921, 5216832.648626], [4670743.007925, 5216843.185735], [4670641.231474, 5216839.526624], [4670607.711196, 5216826.956602], [4670596.807917, 5216815.199868], [4670497.058423, 5216754.789178], [4670451.824943, 5216753.161895], [4670417.899849, 5216751.941291], [4670406.186076, 5216762.884361], [4670349.238744, 5216772.199646], [4670246.246574, 5216802.586297], [4670246.246574, 5216802.586297], [4670188.081851, 5216845.950725], [4670153.345056, 5216867.429264], [4670026.110783, 5216942.399778], [4669945.327034, 5216984.948474], [4669760.327642, 5217091.92945], [4669725.995278, 5217102.056565], [4669589.477986, 5217119.863186], [4669578.169265, 5217119.455262], [4669544.649586, 5217106.881106], [4669533.340884, 5217106.47313], [4669503.073478, 5217003.097034], [4669492.577956, 5216979.988705], [4669492.984479, 5216968.638569], [4669482.489017, 5216945.530315], [4669462.717894, 5216865.263874], [4669452.629168, 5216830.805875], [4669455.881582, 5216740.006606], [4669447.012652, 5216671.49968], [4669440.176578, 5216546.244957], [4669440.176578, 5216546.244957], [4669429.275113, 5216534.487294], [4669429.68167, 5216523.137692], [4669476.133168, 5216490.721048], [4669487.847614, 5216479.779478], [4669546.013034, 5216436.421079], [4669547.232255, 5216402.372629], [4669547.638659, 5216391.023172], [4669582.374938, 5216369.547924], [4669617.517379, 5216336.72319], [4669664.37359, 5216292.956832], [4669688.613979, 5216248.37502], [4669724.567951, 5216192.85178], [4669806.157851, 5216127.609906], [4669818.277521, 5216105.319163], [4669840.892596, 5216106.134229], [4669863.507677, 5216106.94924], [4670019.082444, 5215555.745373], [4670261.393327, 5215428.113251], [4670340.540767, 5215430.961579], [4670351.036844, 5215454.065232], [4670419.688283, 5215433.809245], [4670420.904089, 5215399.764113], [4670420.904089, 5215399.764113], [4670433.021345, 5215377.474174], [4670456.850465, 5215344.242684], [4670502.482402, 5215334.521118], [4670673.702654, 5215295.226264], [4670663.205935, 5215272.123328], [4670621.624556, 5215168.363941], [4670611.533108, 5215133.913199], [4670797.294046, 5215004.239479], [4670797.294046, 5215004.239479], [4670879.271067, 5214927.647816], [4671008.89845, 5214784.593778], [4671068.259885, 5214707.190073], [4671080.374702, 5214684.900811], [4671081.992335, 5214639.510631], [4671082.801142, 5214616.815621], [4671094.511414, 5214605.874018], [4671105.817287, 5214606.279886], [4671128.429037, 5214607.091583], [4671140.543577, 5214584.802466], [4671152.253745, 5214573.860823], [4671174.865427, 5214574.672402], [4671255.218935, 5214543.47018], [4671267.333097, 5214521.181032], [4671260.473265, 5214395.954841], [4671272.587211, 5214373.666022], [4671252.401039, 5214304.771647], [4671288.742382, 5214237.905947], [4671381.206095, 5214184.415174], [4671360.211419, 5214138.216254], [4671360.615444, 5214126.86931], [4671371.920772, 5214127.274814], [4671372.324782, 5214115.927883], [4671384.034092, 5214104.986452], [4671418.757914, 5214083.509026], [4671421.18159, 5214015.42792], [4671410.684298, 5213992.328894], [4671411.896146, 5213958.288607], [4671411.896146, 5213958.288607], [4671423.605211, 5213947.347298], [4671503.144922, 5213938.838165], [4671514.450039, 5213939.243481], [4671605.698462, 5213919.792067], [4671628.712357, 5213909.255725], [4671641.63212, 5213864.274171], [4671653.340812, 5213853.332667], [4671653.340812, 5213853.332667], [4671665.049476, 5213842.391159], [4671665.45311, 5213831.044537], [4671700.982484, 5213786.873459], [4671713.094581, 5213764.585415], [4671713.49815, 5213753.238881], [4671703.403972, 5213718.794303], [4671726.417271, 5213708.257918], [4671738.529202, 5213685.970018], [4671750.237558, 5213675.028583], [4671819.276843, 5213643.419069], [4671820.083702, 5213620.726282], [4671842.28984, 5213632.882471], [4671842.28984, 5213632.882471], [4671923.843194, 5213567.638148], [4671935.147909, 5213568.042925], [4671969.868552, 5213546.564535], [4671981.576475, 5213535.622953], [4672086.946569, 5213437.148574], [4672087.349661, 5213425.802393], [4672144.27551, 5213416.478921], [4672155.983074, 5213405.537256], [4672167.690611, 5213394.595587], [4672168.496592, 5213371.903324], [4672193.9263, 5213293.289719], [4672172.123428, 5213269.7888], [4672189.874999, 5213088.658978], [4672021.908553, 5212719.129069], [4672021.908553, 5212719.129069], [4671883.428883, 5212475.619725], [4671651.706809, 5212308.288776], [4671640.403619, 5212307.883778], [4671531.004624, 5212201.730462], [4671508.802187, 5212189.57552], [4671457.53542, 5212040.070309], [4671459.150258, 5211994.692523], [4671471.260442, 5211972.408894], [4671459.957668, 5211972.003711], [4671449.058612, 5211960.25413], [4671438.159583, 5211948.504552], [4671415.957853, 5211936.349744], [4671394.159958, 5211912.850578], [4671383.261052, 5211901.101], [4671361.059506, 5211888.946131], [4671361.059506, 5211888.946131], [4671329.574614, 5211819.664728], [4671268.221773, 5211635.727159], [4671269.029571, 5211613.039233], [4671283.966795, 5211511.349595], [4671318.681085, 5211489.877964], [4671353.395222, 5211468.406246], [4671377.614567, 5211423.84171], [4671424.437807, 5211380.087691], [4671404.255953, 5211311.215441], [4671305.768758, 5211216.819845], [4671306.980201, 5211182.789455], [4671342.500743, 5211138.631607], [4671353.802515, 5211139.036853], [4671538.262845, 5211043.428704], [4671583.873031, 5211033.705333], [4671595.174701, 5211034.11028], [4671606.476373, 5211034.515213], [4671631.09677, 5210978.608711], [4671666.615051, 5210934.450486], [4671690.83149, 5210889.887511], [4671691.234816, 5210878.544385], [4671691.234816, 5210878.544385], [4671743.296193, 5210687.332322], [4671830.453955, 5210145.316358], [4671830.857044, 5210133.974101], [4671824.393534, 5209997.463496], [4671824.796617, 5209986.121415], [4671824.796617, 5209986.121415], [4671825.199698, 5209974.779347], [4671816.720884, 5209894.980683], [4671817.527047, 5209872.296777], [4671885.328938, 5209874.723923], [4671897.435227, 5209852.444527], [4671930.933174, 5209864.999802], [4671941.830556, 5209876.746174], [4672062.911929, 5209971.930153], [4672073.406813, 5209995.018618], [4672107.308261, 5209996.231367], [4672141.612427, 5209986.101883], [4672153.315594, 5209975.163964], [4672175.916526, 5209975.972281], [4672198.920098, 5209965.438453], [4672233.224069, 5209955.308659], [4672289.323804, 5209968.670956], [4672300.221761, 5209980.417064], [4672323.225219, 5209969.882921], [4672323.225219, 5209969.882921], [4672334.928165, 5209958.944786], [4672334.928165, 5209958.944786], [4672346.631085, 5209948.006646], [4672346.631085, 5209948.006646], [4672380.532442, 5209949.218401], [4672391.832898, 5209949.622292], [4672484.248051, 5209896.142615], [4672506.848857, 5209896.950125], [4672552.050487, 5209898.564984], [4672552.050487, 5209898.564984], [4672552.050487, 5209898.564984], [4672574.651312, 5209899.372332], [4672574.651312, 5209899.372332], [4672585.951726, 5209899.775986], [4672597.654294, 5209888.837588], [4672609.356835, 5209877.899186], [4673042.387386, 5209791.148725], [4673042.387386, 5209791.148725], [4673100.89675, 5209736.454344], [4673112.19702, 5209736.857353], [4673215.906511, 5209683.774416], [4673250.609875, 5209662.299296], [4673273.611592, 5209651.763105], [4673307.913435, 5209641.629633], [4673389.421796, 5209576.39795], [4673401.524227, 5209554.117148], [4673413.225455, 5209543.178073], [4673459.629011, 5209510.7634], [4673667.439091, 5209393.249562], [4673759.842042, 5209339.759945], [4673840.944173, 5209285.867596], [4673840.944173, 5209285.867596], [4673864.344948, 5209263.988893], [4673933.345147, 5209232.376791], [4673933.345147, 5209232.376791], [4673956.745582, 5209210.497967], [4673956.745582, 5209210.497967], [4674037.845532, 5209156.604556], [4674095.945068, 5209113.248458], [4674107.644968, 5209102.308967], [4674142.344273, 5209080.831691], [4674153.643861, 5209081.233391], [4674210.942128, 5209060.559259], [4674202.843809, 5208969.428443], [4674203.243958, 5208958.087355], [4674225.842857, 5208958.890574], [4674225.442734, 5208970.231665], [4674225.442734, 5208970.231665], [4674270.240532, 5208983.179058], [4674292.439457, 5208995.323248], [4674338.037461, 5208985.588086], [4674338.037461, 5208985.588086], [4674349.336955, 5208985.989543], [4674349.736931, 5208974.648422], [4674361.036412, 5208975.049865], [4674361.036412, 5208975.049865], [4674394.934867, 5208976.254111], [4674417.533844, 5208977.056875], [4674508.729385, 5208957.585144], [4674531.328338, 5208958.387631], [4674543.027561, 5208947.447748], [4674577.325669, 5208937.310234], [4674702.418899, 5208919.040134], [4674736.716757, 5208908.902059], [4674805.312269, 5208888.625557], [4674852.506798, 5208833.523892], [4674876.303522, 5208800.302601], [4674911.798648, 5208756.141207], [4674947.692679, 5208700.639016], [4674947.692679, 5208700.639016], [4674914.19433, 5208688.095996], [4674925.892785, 5208677.155913], [4674926.292045, 5208665.815104], [4674915.79142, 5208642.73279], [4674915.79142, 5208642.73279], [4674916.190688, 5208631.392023], [4674905.690123, 5208608.309784], [4674906.089401, 5208596.969058], [4674906.887951, 5208574.287645], [4674907.686496, 5208551.606286], [4674886.685616, 5208505.442231], [4674899.182418, 5208471.821214], [4674899.58169, 5208460.48065], [4674889.081338, 5208437.398815], [4674824.083512, 5208355.61074], [4674847.080418, 5208345.071938], [4674848.278383, 5208311.05075], [4674837.778307, 5208287.969231], [4674838.177636, 5208276.628891], [4674781.284774, 5208285.965057], [4674783.681127, 5208217.92326], [4674840.972895, 5208197.246881], [4674875.667261, 5208175.768724], [4674843.768079, 5208117.865527], [4674801.76889, 5208025.541611], [4674837.660603, 5207970.043987], [4674873.951139, 5207903.206629], [4674909.442746, 5207859.049243], [4674957.030464, 5207792.612963], [4674992.122166, 5207759.79547], [4674992.521261, 5207748.45574], [4674982.021392, 5207725.37575], [4674959.824416, 5207713.234886], [4674948.925521, 5207701.494607], [4674950.522079, 5207656.13606], [4674940.022407, 5207633.056255], [4674929.123625, 5207621.316057], [4674918.62404, 5207598.236317], [4674955.311607, 5207520.061703], [4674955.710724, 5207508.722261], [4674968.604921, 5207463.765198], [4674981.09991, 5207430.147663], [4674974.990279, 5207282.336767], [4674975.389351, 5207270.997604], [4674954.789795, 5207213.500893], [4674990.278324, 5207169.346259], [4674991.076408, 5207146.66821], [4674980.577146, 5207123.5897], [4674980.577146, 5207123.5897], [4674970.476994, 5207089.172289], [4674970.876053, 5207077.833354], [4674959.578768, 5207077.432818], [4674927.682467, 5207019.536689], [4674939.37877, 5207008.598409], [4674929.278873, 5206974.181378], [4674929.278873, 5206974.181378], [4674930.476162, 5206940.165036], [4674930.875255, 5206928.826282], [4674887.283422, 5206881.869062], [4674865.487667, 5206858.390469], [4674865.88683, 5206847.051818], [4674854.989004, 5206835.312541], [4674833.991827, 5206789.156824], [4674834.790214, 5206766.479704], [4674823.892517, 5206754.740496], [4674812.994846, 5206743.001291], [4674802.496429, 5206719.923594], [4674803.294879, 5206697.246644], [4674803.694101, 5206685.908189], [4674804.093322, 5206674.569748], [4674816.986927, 5206629.616795], [4674828.682852, 5206618.679083], [4674852.473777, 5206585.465309], [4674852.87293, 5206574.126981], [4674891.153106, 5206450.608028], [4674880.255683, 5206438.869285], [4674872.55119, 5206336.425789], [4674872.55119, 5206336.425789], [4674875.743997, 5206245.72189], [4674843.451668, 5206199.16852], [4674822.455823, 5206153.015909], [4674823.254119, 5206130.340297], [4674823.653265, 5206119.002511], [4674801.859343, 5206095.525726], [4674792.159958, 5206049.774194], [4674792.559134, 5206038.436507], [4674782.460658, 5206004.022876], [4674772.761442, 5205958.27177], [4674773.160632, 5205946.934193], [4674762.663112, 5205923.858413], [4674752.16564, 5205900.78268], [4674752.56485, 5205889.445172], [4674745.26114, 5205775.670161], [4674746.05955, 5205752.995456], [4674735.961504, 5205718.582823], [4674736.360716, 5205707.245532], [4674736.759926, 5205695.908255], [4674737.159135, 5205684.570991], [4674768.132819, 5205447.292811], [4674756.83749, 5205446.892184], [4674768.531967, 5205435.955839], [4674758.03497, 5205412.881311], [4674760.030739, 5205356.19679], [4674771.725097, 5205345.26054], [4674785.415009, 5205277.640219], [4674786.213231, 5205254.966685], [4674799.104707, 5205210.020347], [4674799.503796, 5205198.683652], [4674800.30197, 5205176.010303], [4674813.193257, 5205131.064309], [4674813.193257, 5205131.064309], [4674813.991385, 5205108.391117], [4674826.084413, 5205086.118503], [4674826.483459, 5205074.781952], [4674826.882503, 5205063.445415], [4674827.281545, 5205052.108891], [4674828.079626, 5205029.435883], [4674840.172513, 5205007.163429], [4674831.271886, 5204938.744387], [4674844.162659, 5204893.799445], [4674844.561665, 5204882.46312], [4674844.561665, 5204882.46312], [4674844.960669, 5204871.126808], [4674844.960669, 5204871.126808], [4674845.758674, 5204848.454226], [4674846.157674, 5204837.117954], [4674846.955669, 5204814.445451], [4674847.753659, 5204791.773002], [4674847.753659, 5204791.773002], [4674848.152651, 5204780.436798], [4674836.858106, 5204780.036328], [4674815.466111, 5204745.226828], [4674794.074268, 5204710.417413], [4674783.976994, 5204676.00862], [4674751.291043, 5204640.798838], [4674645.533275, 5204432.746521], [4674613.247893, 5204386.201496], [4674602.752332, 5204363.129393], [4674581.36209, 5204328.320956], [4674538.582067, 5204258.704336], [4674410.645123, 5204038.521226], [4674387.658407, 5204049.054647], [4673847.966397, 5203961.782677], [4673827.780216, 5203892.968927], [4673957.207248, 5203750.030946], [4673946.31398, 5203738.294619], [4673339.687609, 5203625.919019], [4673329.195962, 5203602.8475], [4673330.798717, 5203557.508955], [4673311.418467, 5203466.028178], [4673336.333776, 5203081.065042], [4673294.369697, 5202988.784588], [4673218.129171, 5202906.632046], [4673185.855856, 5202860.090081], [4673004.31623, 5202558.576657], [4672982.133768, 5202546.43832], [4672927.279473, 5202499.092333], [4672928.883731, 5202453.75916], [4672919.597482, 5202396.690453], [4672897.816598, 5202373.218968], [4673108.542308, 5201529.706466], [4673108.943068, 5201518.374282], [4673108.943068, 5201518.374282], [4672870.578071, 5201226.222343], [4672706.385156, 5200755.188692], [4672515.21475, 5200408.008533], [4672572.463053, 5200387.360979], [4672596.245088, 5200354.174178], [4672655.900028, 5200265.542058], [4672679.681457, 5200232.355444], [4672679.681457, 5200232.355444], [4672702.660475, 5200221.830066], [4672713.949412, 5200222.232662], [4672805.463958, 5200191.461146], [4672888.094431, 5200092.303371], [4672889.297093, 5200058.312015], [4672858.173982, 5199660.145721], [4672814.223666, 5199624.546356], [4672694.866007, 5199484.161202], [4672673.493152, 5199449.366951], [4672642.035832, 5199380.181307], [4672575.913041, 5199332.447196], [4672564.625172, 5199332.044518], [4672498.904395, 5199272.980662], [4672264.627401, 5198867.594731], [4672265.028918, 5198856.265771], [4672266.634968, 5198810.950065], [4672266.634968, 5198810.950065], [4672357.334195, 5198802.844667], [4672369.825572, 5198769.260902], [4672372.635215, 5198689.959207], [4672374.240692, 5198644.644246], [4672388.588266, 5197601.653621], [4672394.606866, 5197431.742874], [4672403.433522, 5197182.545873], [4672403.433522, 5197182.545873], [4672409.45127, 5197012.642528], [4672411.055945, 5196967.335476], [4672407.393018, 5196751.727268], [4672400.922072, 5196615.407831], [4671797.180163, 5196435.080399], [4671785.895801, 5196434.677061], [4671147.521112, 5196275.75407], [4671074.975324, 5196091.714171], [4670963.742102, 5195724.85651], [4670438.262706, 5195569.941754], [4670047.389747, 5195442.515238], [4670047.389747, 5195442.515238], [4670036.106726, 5195442.109906], [4669140.353465, 5195217.123744], [4669113.738879, 5195329.55519], [4668448.462147, 5195294.228104], [4668269.157033, 5195253.737844], [4668279.627827, 5195276.79394], [4668289.286848, 5195322.498865], [4668277.598209, 5195333.415855], [4668140.175168, 5195385.147915], [4668014.033528, 5195437.285946], [4667914.11366, 5195388.317744], [4667858.919192, 5195352.304988], [4667826.290472, 5195317.108019], [4667804.131639, 5195304.967719], [4667651.054736, 5195163.363717], [4667406.91034, 5195041.140421], [4667195.804467, 5194942.786419], [4666815.065342, 5194849.61723], [4666736.499007, 5194835.429325], [4666557.211168, 5194794.909192], [4666523.773367, 5194782.357239], [4666468.179913, 5194757.662576], [4666456.898043, 5194757.253038], [4666423.868596, 5194733.377252], [4666401.304924, 5194732.558061], [4666334.022127, 5194718.776651], [4666278.021334, 5194705.404551], [4666176.893648, 5194690.39276], [4665987.964004, 5194604.159294], [4665923.13476, 5194522.435544], [4665912.261883, 5194510.702152], [4665496.483145, 5194450.224075], [4665473.511144, 5194460.725836], [4664721.349871, 5194331.272882], [4664440.761116, 5193969.565359], [4664408.150083, 5193934.362427], [4664202.850975, 5193677.444886], [4664191.981228, 5193665.710684], [4662405.021968, 5194348.521649], [4662256.304191, 5194399.747605], [4662245.436158, 5194388.010348], [4662245.849166, 5194376.687633], [4662471.469222, 5193455.313271], [4662602.005483, 5192972.635338], [4662640.380043, 5192849.346003], [4662770.898161, 5192366.695501], [4662874.313524, 5192007.758777], [4662534.011242, 5190499.162678], [4662510.489686, 5190214.971364], [4662575.526656, 5189979.368706], [4662665.995728, 5189665.377774], [4662665.995728, 5189665.377774], [4662666.407782, 5189654.060587], [4662668.880072, 5189586.157747], [4662652.922227, 5189404.258735], [4662609.057855, 5189368.653776], [4662409.943581, 5188636.130346], [4662007.393376, 5187601.60591], [4661811.785667, 5187084.587756], [4661693.240641, 5185075.164349], [4661691.051482, 5184825.896064], [4661605.389617, 5182535.053481], [4661594.947948, 5182512.021959], [4661549.88028, 5182510.365187], [4661526.933737, 5182520.845384], [4661460.157815, 5182495.74236], [4661438.036864, 5182483.605059], [4661084.218943, 5182595.148837], [4661061.271729, 5182605.627964], [4660967.002012, 5182715.396837], [4660932.787278, 5182725.460824], [4660418.315995, 5182910.333653], [4660407.048719, 5182909.918041], [4660137.877774, 5182866.012477], [4660127.024989, 5182854.287604], [4659933.409915, 5182903.759256], [4659898.364195, 5182936.437596], [4659873.756084, 5182992.15027], [4659804.90777, 5183023.57969], [4659782.787906, 5183011.437888], [4659737.71858, 5183009.772299], [4659582.881617, 5182924.778034], [4659549.495087, 5182912.219229], [4659528.206076, 5182877.45918], [4659528.621197, 5182866.150292], [4659484.798173, 5182830.556982], [4659463.094381, 5182807.105902], [4659463.509573, 5182795.797102], [4659441.390696, 5182783.654833], [4659331.627859, 5182700.32562], [4659321.191637, 5182677.291431], [4659235.210999, 5182560.8703], [4659212.677504, 5182560.036316], [4658772.027657, 5182577.6883], [4658738.227492, 5182576.435646], [4658670.211095, 5182585.23844], [4658636.410934, 5182583.985421], [4658613.461322, 5182594.458474], [4658613.461322, 5182594.458474], [4658590.927869, 5182593.623005], [4658579.661144, 5182593.20525], [4658535.426805, 5182568.9172], [4658524.160115, 5182568.499382], [4658479.509707, 5182555.519554], [4658447.375191, 5182509.032333], [4658415.657384, 5182451.23695], [4658404.807257, 5182439.510724], [4658238.725802, 5182354.082504], [4658227.459395, 5182353.664353], [4658204.926586, 5182352.828012], [4658194.076836, 5182341.101681], [4658015.482275, 5182289.176514], [4657992.949659, 5182288.339681], [4657937.035099, 5182274.939327], [4657926.602738, 5182251.904794], [4657927.019697, 5182240.596798], [4657916.170426, 5182228.870307], [4657768.875299, 5182246.044412], [4657768.458152, 5182257.352399], [4657665.392902, 5182298.815636], [4657631.594049, 5182297.559114], [4657329.075702, 5182241.013178], [4657306.961027, 5182228.8668], [4657295.694859, 5182228.447553], [4657284.846411, 5182216.720388], [4657219.33849, 5182157.665279], [4657207.654611, 5182168.553763], [4657195.970706, 5182179.442243], [4657173.438509, 5182178.603481], [4656955.224568, 5181977.982068], [4656944.794923, 5181954.947287], [4656934.365327, 5181931.912552], [4656901.404275, 5181908.038507], [4656889.72037, 5181918.926312], [4656867.188848, 5181918.086873], [4656767.051984, 5181880.386321], [4656756.20459, 5181868.659022], [4656443.696642, 5181777.746285], [4656409.481282, 5181787.792857], [4656060.24968, 5181774.758236], [4656026.453155, 5181773.49614], [4655946.756133, 5181793.165292], [4655924.225093, 5181792.323634], [4655821.15785, 5181833.764622], [4655786.941731, 5181843.808961], [4655752.725545, 5181853.853184], [4655707.243711, 5181863.476189], [4655462.68977, 5182069.470966], [4655451.004094, 5182080.357091], [4655422.665456, 5181932.095669], [4655423.085352, 5181920.788295], [4655412.659546, 5181897.752134], [4655390.968224, 5181874.294541], [4655325.054898, 5181826.536302], [4655314.629427, 5181803.500274], [4655191.549652, 5181776.247839], [4655180.284226, 5181775.82612], [4655091.421691, 5181738.53047], [4655069.731538, 5181715.072582], [4654836.524224, 5181615.75474], [4654794.316302, 5181840.629882], [4654793.054398, 5181874.551573], [4654683.670259, 5182085.591144], [4654672.404517, 5182085.16879], [4654432.876716, 5182155.448777], [4654421.189811, 5182166.333668], [4654409.081758, 5182188.526132], [4654396.552506, 5182222.026241], [4654290.525729, 5182342.605847], [4654280.102303, 5182319.567529], [4654235.881081, 5182295.260617], [4654213.770557, 5182283.10711], [4654112.377259, 5182279.300244], [4654100.689848, 5182290.184857], [4654077.736472, 5182300.646384], [4654055.204603, 5182299.80018], [4653942.967036, 5182284.260705], [4653931.701133, 5182283.837451], [4653865.792847, 5182236.067206], [4653865.792847, 5182236.067206], [4653843.261171, 5182235.220511], [4653831.995336, 5182234.797143], [4653821.151326, 5182223.066192], [4653809.885507, 5182222.642799], [4653628.366471, 5182249.789367], [4653592.880593, 5182293.748845], [4653569.082446, 5182326.824413], [4653546.128456, 5182337.284658], [4653501.486972, 5182324.281996], [4653501.909183, 5182312.974351], [4653347.143559, 5182227.887212], [4653329.964043, 5182385.76985], [4653340.385188, 5182408.809272], [4653336.583422, 5182510.579423], [4653324.894872, 5182521.463285], [4653105.343677, 5182660.40774], [4653083.23389, 5182648.251154], [4653049.435151, 5182646.978176], [4653015.213607, 5182657.013066], [4652796.501194, 5182773.335694], [4652774.391578, 5182761.178249], [4652641.735107, 5182688.232871], [4652607.51305, 5182698.266302], [4652133.483793, 5182703.025592], [4652111.799149, 5182679.558794], [4651908.583869, 5182683.206176], [4651886.051525, 5182682.354736], [4651828.448001, 5182714.149673], [4651817.1818, 5182713.723862], [4651584.412617, 5182603.008094], [4651572.722046, 5182613.889797], [4651467.930365, 5182700.51707], [4651467.505705, 5182711.824968], [4651508.748837, 5182815.301538], [4651497.482548, 5182814.875336], [4651497.057912, 5182826.183372], [4651496.633274, 5182837.491421], [4651439.027597, 5182869.284396], [4651416.494907, 5182868.431802], [4651235.80867, 5182872.917189], [4651201.584694, 5182882.945624], [4651122.72036, 5182879.959324], [4651111.454033, 5182879.532656], [4651001.342219, 5182807.417179], [4650990.501226, 5182795.682412], [4650892.082797, 5182712.685316], [4650892.082797, 5182712.685316], [4650793.240645, 5182640.995741], [4650793.666097, 5182629.687993], [4650717.357379, 5182558.852333], [4650706.942565, 5182535.809945], [4650631.486497, 5182442.359307], [4650631.912121, 5182431.051809], [4650609.806276, 5182418.889901], [4650610.231924, 5182407.582433], [4650599.817523, 5182384.540309], [4650600.243179, 5182373.232883], [4650552.003231, 5182156.258123], [4650552.003231, 5182156.258123], [4650512.901836, 5181996.250096], [4650503.339539, 5181950.595032], [4650496.331703, 5181837.099268], [4650452.548908, 5181801.469693], [4650452.97468, 5181790.162967], [4650430.870533, 5181778.001532], [4650408.766443, 5181765.840063], [4650397.927337, 5181754.105978], [4650375.823348, 5181741.944467], [4650364.558439, 5181741.517024], [4650342.454524, 5181729.355454], [4650330.763722, 5181740.234614], [4650262.748341, 5181748.976079], [4650262.748341, 5181748.976079], [4650251.483435, 5181748.5485], [4650251.483435, 5181748.5485], [4650240.218531, 5181748.120909], [4650240.218531, 5181748.120909], [4650217.688727, 5181747.265685], [4650206.423828, 5181746.838053], [4650172.203039, 5181756.861723], [4650160.938133, 5181756.434036], [4650138.834466, 5181744.271981], [4650127.569579, 5181743.844256], [4649994.096288, 5181693.484165], [4649982.831474, 5181693.056273], [4649526.951473, 5181517.211607], [4649504.849225, 5181505.048438], [4649460.217985, 5181492.028259], [4649437.688942, 5181491.171231], [4649414.732933, 5181501.620419], [4649380.512337, 5181511.640969], [4649063.396341, 5181544.860067], [4649018.765617, 5181531.83777], [4648862.772928, 5181480.605157], [4648851.508479, 5181480.17594], [4648818.142819, 5181467.582027], [4648806.87839, 5181467.152759], [4648647.892916, 5181495.060111], [4648637.056365, 5181483.324455], [4648636.628472, 5181494.630638], [4648625.364029, 5181494.20115], [4648432.584339, 5181520.816366], [4648421.319885, 5181520.386634], [4648410.483598, 5181508.650698], [4648376.690293, 5181507.361386], [4648320.796419, 5181493.906101], [4648309.96029, 5181482.17009], [4648298.695895, 5181481.740216], [4648298.2676, 5181493.046363], [4648106.772901, 5181485.736428], [4648095.508521, 5181485.306311], [4647985.436796, 5181413.168006], [4647985.865454, 5181401.861984], [4643819.16237, 5176216.075654], [4643796.646912, 5176215.206277], [4643097.803168, 5176210.827929], [4642841.852144, 5176710.164454], [4642829.72535, 5176732.328541], [4642791.607239, 5176844.021415], [4642779.480146, 5176866.185733], [4642549.446008, 5177570.270156], [4642499.191965, 5177704.137146], [4642382.150946, 5178401.33907], [4642379.540968, 5178469.150819], [4642377.750823, 5178808.653372], [4642376.880744, 5178831.258192], [4642375.140566, 5178876.467991], [4642360.834377, 5178955.14897], [4642256.005539, 5179041.639097], [4642221.35234, 5179062.933912], [4642169.343606, 5179242.030816], [4642156.776442, 5179275.502576], [4642110.366024, 5179601.981819], [4642097.798122, 5179635.454723], [4642094.749908, 5179714.578428], [4642092.137088, 5179782.399262], [4642066.93885, 5180143.681281], [4642030.103192, 5180221.497582], [4641866.261813, 5180667.983362], [4641841.9928, 5180712.326652], [4641747.530383, 5180821.872701], [4641747.094393, 5180833.177407], [4641527.34704, 5181266.191006], [4641448.066509, 5181274.43049], [4641436.366649, 5181285.297682], [4641425.103182, 5181284.859653], [4641388.257545, 5181362.682249], [4641364.420943, 5181395.721991], [4641355.254052, 5181633.136937], [4641294.56861, 5181744.002707], [4641148.480794, 5182021.389959], [4641159.745102, 5182021.828392], [4641293.606982, 5182061.006813], [4641305.307991, 5182050.138972], [4641396.295964, 5182031.032395], [4641430.089004, 5182032.346772], [4641415.769105, 5182111.051602], [4641414.896075, 5182133.663991], [4641362.416293, 5182324.118678], [4641339.886923, 5182323.24222], [4641300.852785, 5182457.6054], [4641286.96773, 5182525.006781], [4641237.103604, 5182647.627301], [4641246.621583, 5182693.29298], [4641233.609315, 5182738.082076], [4641267.40481, 5182739.397249], [4641209.768527, 5182771.125976], [4641175.536072, 5182781.117525], [4641173.788595, 5182826.34541], [4641184.616996, 5182838.0909], [4641172.914846, 5182848.959431], [4641159.901988, 5182893.749126], [4641136.497466, 5182915.486241], [4641136.060539, 5182926.793346], [4641162.429338, 5183120.331829], [4641161.992421, 5183131.639178], [4641159.807811, 5183188.176121], [4641182.339187, 5183189.053184], [4641154.127629, 5183335.173726], [4641153.69068, 5183346.481327], [4641115.523091, 5183458.242249], [4641102.946025, 5183491.726877], [4641102.946025, 5183491.726877], [4641102.946025, 5183491.726877], [4641051.325527, 5183659.590185], [4641051.325527, 5183659.590185], [4640956.38632, 5183780.468256], [4640988.873852, 5183815.709106], [4641032.628079, 5183851.388756], [4641032.628079, 5183851.388756], [4641140.922531, 5183968.858448], [4641162.581741, 5183992.352425], [4641293.412963, 5184110.699493], [4641270.442498, 5184121.131031], [4641311.57811, 5184224.662333], [4641806.015667, 5184277.868328], [4641938.531328, 5184645.447867], [4641913.815446, 5184701.118538], [4641896.366657, 5185153.500332], [4644055.973708, 5185044.61914], [4644078.510059, 5185045.489687], [4644271.369595, 5185018.957439], [4644250.9989, 5185256.033078], [4642849.327838, 5185609.584965], [4643025.070467, 5187202.351621], [4642685.210532, 5187234.492868], [4643165.341945, 5188544.725814], [4642923.836483, 5188660.005802], [4642889.584062, 5188670.008783], [4642785.955282, 5188722.645205], [4642762.974912, 5188733.084942], [4642689.241001, 5188888.860256], [4642829.251701, 5189064.260251], [4642677.532717, 5188899.73724], [4642505.828569, 5188961.061843], [4641979.789414, 5189427.885808], [4641956.369894, 5189449.639097], [4641804.577229, 5189579.720123], [4641793.303924, 5189579.281687], [4641232.937127, 5190056.090897], [4641174.817656, 5190099.157076], [4641045.989885, 5190218.796486], [4641034.278109, 5190229.672775], [4640827.404089, 5190323.602747], [4640713.786949, 5190341.836962], [4639906.304056, 5190491.629572], [4639815.232055, 5190510.734661], [4638934.968696, 5190498.935769], [4638697.772401, 5190500.967811], [4638516.064957, 5190527.837818], [4638414.157283, 5190535.171063], [4637663.443733, 5190675.669203], [4637561.53425, 5190682.993253], [4636864.309814, 5190610.201498], [4636517.724003, 5190233.878753], [4636437.730361, 5189970.073316], [4635755.764189, 5188934.609176], [4635594.954167, 5188429.692793], [4635486.238901, 5188323.418591], [4635331.997597, 5188226.67329], [4634794.986758, 5188964.56866], [4634585.483624, 5191132.099313], [4634108.220897, 5192926.727308], [4635239.310736, 5195182.357559], [4635408.245344, 5198069.483086], [4634700.22848, 5202272.899563], [4634364.956238, 5202747.512624], [4633781.688232, 5205777.281301], [4632508.693514, 5209643.423186], [4632456.399493, 5210390.839852], [4632455.949408, 5210402.17848], [4632467.696503, 5210391.291586], [4632468.59664, 5210368.614367], [4632479.443571, 5210380.404689], [4632490.740571, 5210380.856396], [4632490.290528, 5210392.195016], [4632489.840484, 5210403.533649], [4632501.137513, 5210403.985345], [4632511.534504, 5210427.114342], [4632511.534504, 5210427.114342], [4632511.534504, 5210427.114342], [4632511.534504, 5210427.114342], [4632511.534504, 5210427.114342], [4632511.084481, 5210438.453019], [4632534.578618, 5210416.679007], [4632523.28157, 5210416.227349], [4632523.731576, 5210404.888697], [4632524.18158, 5210393.550058], [4632524.18158, 5210393.550058], [4632535.4786, 5210394.001712], [4632580.6667, 5210395.808194], [4632627.204466, 5210363.598577], [4632650.698157, 5210341.824424], [4632661.995129, 5210342.275921], [4632684.589079, 5210343.178874], [4632694.986467, 5210366.30754], [4632706.283473, 5210366.758986], [4632717.580481, 5210367.21042], [4632717.580481, 5210367.21042], [4632729.327246, 5210356.323223], [4632729.776999, 5210344.98462], [4632730.226751, 5210333.646031], [4632776.76373, 5210301.435846], [4632788.060668, 5210301.887188], [4632788.060668, 5210301.887188], [4632788.510346, 5210290.548643], [4632822.850765, 5210280.564047], [4632823.300399, 5210269.225524], [4632834.597303, 5210269.676806], [4632846.343815, 5210258.789563], [4632846.793419, 5210247.451063], [4632858.989475, 5210225.225353], [4632870.286331, 5210225.676589], [4632870.735903, 5210214.338126], [4632906.42455, 5210170.338008], [4632918.620363, 5210148.112388], [4632929.917133, 5210148.563544], [4632930.816117, 5210125.886802], [4632954.308532, 5210104.112371], [4632966.504143, 5210081.886834], [4632977.80084, 5210082.337925], [4632977.80084, 5210082.337925], [4632977.80084, 5210082.337925], [4632978.250268, 5210070.999621], [4632978.250268, 5210070.999621], [4632966.953585, 5210070.548531], [4632966.953585, 5210070.548531], [4632967.403026, 5210059.210241], [4632967.403026, 5210059.210241], [4632979.149121, 5210048.323052], [4632979.149121, 5210048.323052], [4632990.445779, 5210048.774125], [4632979.598544, 5210036.984787], [4632991.344597, 5210026.097606], [4632991.344597, 5210026.097606], [4632991.794004, 5210014.759367], [4632991.794004, 5210014.759367], [4633003.090624, 5210015.210421], [4633027.481316, 5209970.759645], [4633038.777887, 5209971.210653], [4633038.777887, 5209971.210653], [4633050.523791, 5209960.323465], [4633039.676574, 5209948.534307], [4633086.210625, 5209916.323749], [4633109.252906, 5209905.887475], [4633120.549409, 5209906.338378], [4633120.998649, 5209895.000267], [4633120.998649, 5209895.000267], [4633132.744365, 5209884.113054], [4633144.490053, 5209873.225839], [4633155.786521, 5209873.676696], [4633167.532171, 5209862.789461], [4633168.430528, 5209840.113345], [4633168.430528, 5209840.113345], [4633179.726959, 5209840.56417], [4633191.023391, 5209841.014982], [4633191.47254, 5209829.67694], [4633202.768961, 5209830.127737], [4633191.921688, 5209818.338912], [4633238.903685, 5209774.790004], [4633298.079586, 5209709.015879], [4633298.079586, 5209709.015879], [4633335.560148, 5209619.664969], [4633359.050374, 5209597.890577], [4633371.244355, 5209575.665616], [4633360.397139, 5209563.877303], [4633371.693262, 5209564.32787], [4633383.438277, 5209553.440688], [4633395.632141, 5209531.215793], [4633419.122007, 5209509.441436], [4633430.8669, 5209498.554251], [4633465.652635, 5209477.230317], [4633489.590963, 5209444.118277], [4633489.590963, 5209444.118277], [4633501.335695, 5209433.231072], [4633512.631677, 5209433.681456], [4633535.672342, 5209423.244587], [4633547.416997, 5209412.357344], [4633559.161625, 5209401.470097], [4633559.161625, 5209401.470097], [4633615.192795, 5209415.059102], [4633659.479599, 5209439.535222], [4633659.479599, 5209439.535222], [4633671.22414, 5209428.6478], [4633682.071612, 5209440.435599], [4633704.663633, 5209441.335922], [4633715.959646, 5209441.786064], [4633727.25566, 5209442.236192], [4633738.551677, 5209442.686306], [4633782.838952, 5209467.161938], [4633782.838952, 5209467.161938], [4633828.47152, 5209457.624392], [4633828.47152, 5209457.624392], [4633907.095615, 5209472.111754], [4633907.095615, 5209472.111754], [4633917.943441, 5209483.899351], [4633940.535614, 5209484.799119], [4633963.575985, 5209474.361131], [4633975.320241, 5209463.473276], [4633975.320241, 5209463.473276], [4634009.656583, 5209453.485013], [4634009.208448, 5209464.822695], [4634032.248703, 5209454.384555], [4634077.881016, 5209444.845798], [4634168.697455, 5209437.105303], [4634190.841653, 5209449.342143], [4634191.289569, 5209438.004461], [4634259.513788, 5209429.363931], [4634270.809844, 5209429.813407], [4634305.145803, 5209419.824082], [4634328.185655, 5209409.385246], [4634362.07378, 5209410.733381], [4634362.07378, 5209410.733381], [4634385.113553, 5209400.294412], [4634441.146133, 5209413.878558], [4634475.481883, 5209403.888617], [4634486.777932, 5209404.337832], [4634486.777932, 5209404.337832], [4634508.922502, 5209416.573899], [4634531.514639, 5209417.472238], [4634554.554262, 5209407.032839], [4634588.889888, 5209397.042485], [4634622.778051, 5209398.38968], [4634634.074108, 5209398.838719], [4634656.666229, 5209399.736754], [4634679.705685, 5209389.29706], [4634713.593849, 5209390.643927], [4634736.633227, 5209380.204099], [4634736.633227, 5209380.204099], [4634759.225325, 5209381.101886], [4634758.778092, 5209392.439561], [4634858.654272, 5209441.829843], [4634992.420145, 5209492.565269], [4634992.420145, 5209492.565269], [4635014.118682, 5209516.13815], [4635048.007403, 5209517.483855], [4635058.856757, 5209529.270265], [4635091.851836, 5209553.291601], [4635126.634336, 5209531.961242], [4635137.930605, 5209532.409691], [4635137.930605, 5209532.409691], [4635149.226876, 5209532.858126], [4635160.523148, 5209533.306548], [4635183.115698, 5209534.203352], [4635206.15497, 5209523.762211], [4635228.747507, 5209524.658903], [4635330.414008, 5209528.693352], [4635342.156846, 5209517.803659], [4635376.045675, 5209519.148187], [4635398.638236, 5209520.044472], [4635466.862364, 5209511.3951], [4635489.454926, 5209512.291166], [4635500.751209, 5209512.739178], [4635501.19757, 5209501.401283], [4635512.047495, 5209513.187178], [4635523.343782, 5209513.635163], [4635535.532709, 5209491.407349], [4635546.828973, 5209491.855304], [4635594.245275, 5209436.957715], [4635616.391471, 5209449.191292], [4635628.133895, 5209438.301313], [4635639.876293, 5209427.41133], [4635651.172491, 5209427.859154], [4635651.172491, 5209427.859154], [4635685.507228, 5209417.864729], [4635696.80342, 5209418.312497], [4635787.173015, 5209421.894158], [4635821.061642, 5209423.237058], [4635832.357854, 5209423.684665], [4635843.208124, 5209435.470097], [4635941.753435, 5209518.863201], [4635963.900303, 5209531.096096], [4636041.191944, 5209579.579982], [4636052.042653, 5209591.365387], [4636085.486293, 5209604.045453], [4636164.115931, 5209618.514421], [4636175.41241, 5209618.961637], [4636198.450916, 5209608.517934], [4636220.598347, 5209620.750367], [4636266.675229, 5209599.862685], [4636277.971697, 5209600.309776], [4636289.268167, 5209600.756854], [4636323.157588, 5209602.098008], [4636357.492372, 5209592.100948], [4636357.492372, 5209592.100948], [4636380.530632, 5209581.656816], [4636472.237977, 5209551.21786], [4636598.279045, 5209510.7802], [4636644.354638, 5209489.890846], [4636762.211853, 5209369.639208], [4636792.365964, 5209177.790333], [4636795.034653, 5209109.764734], [4636785.073075, 5209075.305698], [4636785.517859, 5209063.968187], [4636775.556356, 5209029.509311], [4636775.556356, 5209029.509311], [4636753.409492, 5209017.278971], [4636753.409492, 5209017.278971], [4636777.780291, 5208972.822165], [4636789.076068, 5208973.268579], [4636789.076068, 5208973.268579], [4636789.076068, 5208973.268579], [4636790.410368, 5208939.256447], [4636815.225511, 5208883.462589], [4636841.819111, 5208782.320163], [4636854.004011, 5208760.092151], [4636900.519988, 5208727.86586], [4636946.146548, 5208718.313631], [4636980.922055, 5208696.977944], [4636993.106519, 5208674.74993], [4637084.358897, 5208655.644432], [4637130.429291, 5208634.75432], [4637153.464416, 5208624.309193], [4637233.864868, 5208593.419372], [4637256.455616, 5208594.311018], [4637336.855516, 5208563.420387], [4637371.185599, 5208553.420489], [4637382.924956, 5208542.529194], [4637508.949121, 5208502.082795], [4637576.720906, 5208504.75554], [4637701.412969, 5208498.317377], [4637724.003587, 5208499.207884], [4637746.594213, 5208500.098338], [4637758.333093, 5208489.206612], [4637758.333093, 5208489.206612], [4637814.809628, 5208491.432435], [4637826.10494, 5208491.877559], [4637859.547443, 5208504.549798], [4637859.547443, 5208504.549798], [4637870.842775, 5208504.99487], [4637871.286206, 5208493.65792], [4637904.728782, 5208506.330004], [4637972.057531, 5208520.336888], [4637983.352894, 5208520.781827], [4638062.863684, 5208512.559031], [4638096.306615, 5208525.230475], [4638141.48815, 5208527.009557], [4638186.226655, 5208540.125447], [4638230.522285, 5208564.578206], [4638252.670189, 5208576.804534], [4638331.295546, 5208591.253613], [4638491.203277, 5208552.127205], [4638503.384093, 5208529.897397], [4638556.532811, 5208327.60966], [4638556.975405, 5208316.27285], [4638603.041215, 5208295.376046], [4638685.204433, 5208219.127647], [4638754.744318, 5208176.44503], [4638800.366757, 5208166.884158], [4638822.956816, 5208167.771967], [4638822.956816, 5208167.771967], [4638890.727032, 5208170.435072], [4638913.317118, 5208171.322665], [4638913.317118, 5208171.322665], [4638947.202259, 5208172.653955], [4638993.266588, 5208151.755484], [4639038.888722, 5208142.193465], [4639050.625732, 5208131.300446], [4639050.625732, 5208131.300446], [4639074.099673, 5208109.514397], [4639108.868472, 5208088.171881], [4639156.257621, 5208033.263116], [4639167.994363, 5208022.370062], [4639193.67677, 5207943.901631], [4639408.021846, 5207668.473783], [4639510.11379, 5207661.125362], [4639635.235875, 5207643.325468], [4639646.530368, 5207643.768327], [4639694.355357, 5207577.523103], [4639752.150754, 5207545.728767], [4639763.886218, 5207534.835465], [4639764.768364, 5207512.163484], [4639777.38588, 5207478.598298], [4639789.12123, 5207467.705036], [4639789.12123, 5207467.705036], [4639823.886127, 5207446.361128], [4639858.209919, 5207436.353022], [4639869.945127, 5207425.4597], [4639892.533645, 5207426.344798], [4639949.886652, 5207405.885538], [4640006.798656, 5207396.76182], [4640063.710566, 5207387.637762], [4640075.004799, 5207388.080082], [4640131.916611, 5207378.955614], [4640154.945665, 5207368.504221], [4640165.799305, 5207380.282286], [4640177.09354, 5207380.724483], [4640210.976255, 5207382.050992], [4640222.711009, 5207371.157271], [4640258.355573, 5207327.140271], [4640259.236497, 5207304.468679], [4640306.174739, 5207260.893858], [4640353.552891, 5207205.983298], [4640411.343949, 5207174.185944], [4640433.931981, 5207175.069694], [4640468.25424, 5207165.059573], [4640503.016587, 5207143.71371], [4640571.660687, 5207123.692895], [4640628.570565, 5207114.565583], [4640651.598473, 5207104.113209], [4640674.186389, 5207104.996371], [4640866.623658, 5207101.165456], [4640900.945264, 5207091.153803], [4640991.297047, 5207094.683728], [4641161.585658, 5207078.628772], [4641228.910275, 5207092.610043], [4641523.432749, 5207081.397628], [4641557.314812, 5207082.719214], [4641568.608836, 5207083.159715], [4641602.490919, 5207084.48114], [4641702.821103, 5207122.451773], [4641736.264685, 5207135.108455], [4641771.901561, 5207091.086444], [4641783.634239, 5207080.191009], [4641796.682699, 5207035.288643], [4641809.292445, 5207001.722042], [4641879.248681, 5206947.68519], [4641890.981057, 5206936.789771], [4641937.471873, 5206904.543534], [4641994.3795, 5206895.40806], [4642028.699354, 5206885.392423], [4642098.215308, 5206842.689919], [4642202.050003, 5206789.97087], [4642225.513618, 5206768.17953], [4642408.402543, 5206718.535921], [4642431.865524, 5206696.7442], [4642443.159179, 5206697.183616], [4642490.084772, 5206653.600071], [4642706.41356, 5206616.604282], [4642795.887577, 5206642.787035], [4643288.44094, 5206775.443218], [4643288.44094, 5206775.443218], [4643310.591844, 5206787.655481], [4643355.767266, 5206789.408898], [4643366.187715, 5206812.518231], [4643377.481603, 5206812.956541], [4643456.102267, 5206827.359876], [4643467.83277, 5206816.462538], [4643501.277938, 5206829.112612], [4643500.841389, 5206840.448171], [4643500.841389, 5206840.448171], [4643500.841389, 5206840.448171], [4643522.119685, 5206875.331232], [4643533.413664, 5206875.769362], [4643564.676736, 5206945.097611], [4643586.391952, 5206968.645197], [4643661.086909, 5207085.069408], [4643671.94478, 5207096.843273], [4643682.802678, 5207108.617142], [4643704.518555, 5207132.16489], [4643714.503881, 5207166.61069], [4643725.798225, 5207167.04862], [4643779.216198, 5207248.590283], [4643800.932628, 5207272.138179], [4643950.770268, 5207493.655577], [4643982.474326, 5207551.650695], [4644207.899797, 5207866.928638], [4644240.042385, 5207913.588369], [4644389.900027, 5208135.114595], [4644411.184365, 5208170.000659], [4644432.904432, 5208193.549539], [4644432.904432, 5208193.549539], [4644604.491879, 5208438.628735], [4644604.056482, 5208449.966312], [4644711.357583, 5208601.725593], [4644732.644103, 5208636.612737], [4644816.921357, 5208798.838187], [4644828.217752, 5208799.274963], [4644814.310253, 5208866.866537], [4644814.310253, 5208866.866537], [4644814.310253, 5208866.866537], [4644813.439871, 5208889.542761], [4644813.439871, 5208889.542761], [4644813.439871, 5208889.542761], [4644810.828687, 5208957.571753], [4644819.949304, 5209014.699756], [4644819.949304, 5209014.699756], [4644819.514106, 5209026.038037], [4644829.940397, 5209049.151437], [4644817.773297, 5209071.391293], [4644827.329233, 5209117.181573], [4644827.329233, 5209117.181573], [4644825.588425, 5209162.535265], [4644825.153218, 5209173.873721], [4644836.45006, 5209174.310525], [4644836.014865, 5209185.648997], [4644843.830212, 5209276.794055], [4644843.830212, 5209276.794055], [4644843.395016, 5209288.132648], [4644843.395016, 5209288.132648], [4644842.959818, 5209299.471255], [4644842.524619, 5209310.809875], [4644851.645669, 5209367.939982], [4644851.210473, 5209379.278684], [4644849.034468, 5209435.972396], [4644859.896431, 5209447.747982], [4644859.896431, 5209447.747982], [4644859.461236, 5209459.086779], [4644856.850036, 5209527.119845], [4644856.41483, 5209538.458736], [4644856.41483, 5209538.458736], [4644856.41483, 5209538.458736], [4644875.0927, 5209641.382981], [4644874.657504, 5209652.72201], [4644878.991776, 5209834.585101], [4644878.556565, 5209845.924358], [4644877.250923, 5209879.942211], [4644886.807783, 5209925.736354], [4644897.235128, 5209948.851909], [4644896.799928, 5209960.191304], [4644904.616155, 5210051.343753], [4644903.745749, 5210074.0228], [4644915.043668, 5210074.459601], [4644914.608476, 5210085.799146], [4644944.585844, 5210189.166025], [4644954.578434, 5210223.621886], [4644974.563817, 5210292.533958], [4644974.128674, 5210303.873767], [4644984.55661, 5210326.990169], [4644994.549469, 5210361.446497], [4644994.114343, 5210372.78639], [4645025.398648, 5210442.136188], [4645215.714213, 5211085.492958], [4645236.137961, 5211143.070019], [4645261.772695, 5211359.857916], [4645261.337787, 5211371.199019], [4645260.033052, 5211405.222406], [4645247.428726, 5211438.809387], [4645234.824306, 5211472.396465], [4645233.9544, 5211495.078944], [4645206.570228, 5211618.960363], [4645193.965397, 5211652.548001], [4645153.974953, 5211810.01942], [4645142.239851, 5211820.924353], [4645152.234614, 5211855.385999], [4645139.629241, 5211888.974372], [4645126.153521, 5211945.246366], [4645125.718391, 5211956.588148], [4645125.28326, 5211967.929943], [4645125.28326, 5211967.929943], [4645113.983069, 5211967.493202], [4645124.848128, 5211979.271752], [4645113.547923, 5211978.835009], [4645113.112775, 5211990.17683], [4645098.766384, 5212069.133179], [4645110.066695, 5212069.569949], [4645110.066695, 5212069.569949], [4645132.232186, 5212081.785378], [4645310.863028, 5212145.481436], [4645333.028973, 5212157.69651], [4645386.052448, 5212250.615743], [4645396.918167, 5212262.394359], [4645407.349086, 5212285.515178], [4645418.21487, 5212297.293815], [4645459.93919, 5212389.777631], [4645512.095686, 5212505.383454], [4645585.551483, 5212655.890899], [4645658.574947, 5212817.743105], [4645669.441635, 5212829.522151], [4645680.308351, 5212841.3012], [4645742.033261, 5213002.719861], [4645741.59876, 5213014.062958], [4645727.69014, 5213081.685706], [4645715.084939, 5213115.279178], [4645650.318969, 5213328.621757], [4645625.107198, 5213395.810272], [4645623.803152, 5213429.840966], [4645559.902247, 5213620.50211], [4645559.902247, 5213620.50211], [4645559.467466, 5213631.845921], [4645520.777685, 5213755.319463], [4645508.170759, 5213788.91495], [4645456.872247, 5213945.986204], [4645456.43731, 5213957.33039], [4645455.567431, 5213980.018802], [4645431.657287, 5214013.178401], [4645430.787338, 5214035.866941], [4645417.744685, 5214080.80759], [4645417.744685, 5214080.80759], [4645405.571928, 5214103.05968], [4645145.559994, 5214979.222969], [4645144.689167, 5215001.91374], [4645342.065291, 5215168.615195], [4645353.369313, 5215169.051986], [4646110.742557, 5215198.28624], [4646122.046691, 5215198.722112], [4646921.177958, 5215320.401803], [4646921.177958, 5215320.401803], [4647186.4209, 5215489.681282], [4647208.597082, 5215501.896689], [4647252.516671, 5215537.673644], [4647252.083718, 5215549.019899], [4647351.228759, 5215621.008177], [4647516.473889, 5215740.987679], [4647813.06117, 5215979.64139], [4647823.934092, 5215991.422138], [4647823.934092, 5215991.422138], [4647823.934092, 5215991.422138], [4647823.069458, 5216014.115854], [4647967.013163, 5216099.184109], [4648185.271083, 5216016.647116], [4648196.576401, 5216017.080584], [4648197.008273, 5216005.733678], [4648533.060666, 5215802.70877], [4648602.616743, 5215759.920047], [4649027.36764, 5215605.730785], [4649061.713184, 5215595.681492], [4649118.237727, 5215597.843235], [4649118.668456, 5215586.496733], [4649356.50215, 5215584.22581], [4649548.686035, 5215591.568332], [4649524.903761, 5215920.1919], [4649499.397956, 5216294.216019], [4649562.069382, 5216432.976894], [4649643.05278, 5216686.080879], [4649596.106675, 5216729.74508], [4649489.615542, 5216850.685368], [4649406.595874, 5216949.793792], [4649194.462635, 5217168.97862], [4649111.437063, 5217268.087474], [4649121.020383, 5217313.914024], [4649062.330777, 5217368.494282], [4648509.236614, 5217620.084285], [4648440.097863, 5217651.531121], [4648475.805603, 5219391.967843], [4648486.683104, 5219403.752254], [4648682.91438, 5219604.520973], [4648693.792381, 5219616.305429], [4648725.563334, 5219674.3614], [4648734.715071, 5219731.551283], [4648728.240852, 5219901.823384], [4648700.872566, 5220025.825021], [4648772.274936, 5220233.190821], [4648804.479853, 5220279.898357], [4649022.062884, 5220515.602812], [4649307.954116, 5220742.551781], [4649330.145242, 5220754.769599], [4649341.456317, 5220755.202169], [4649423.327219, 5220985.71817], [4649429.898679, 5221111.033721], [4649449.505484, 5221191.370592], [4649459.955328, 5221214.509448], [4649459.524443, 5221225.862661], [4649513.066942, 5221307.497758], [4650097.106881, 5221739.128056], [4650185.88525, 5221787.997392], [4650207.649941, 5221811.568624], [4650429.171031, 5221945.093567], [4650429.171031, 5221945.093567], [4650429.171031, 5221945.093567], [4650739.483076, 5222127.481572], [4650795.188596, 5222152.345395], [4651596.693977, 5222228.327665], [4651732.45078, 5222233.486727], [4652219.76997, 5222229.247954], [4652266.305346, 5222196.900843], [4652322.443241, 5222210.401323], [4652389.46696, 5222235.685258], [4652512.629646, 5222274.468262], [4652523.942851, 5222274.897164], [4652560.018872, 5222219.410067], [4652609.116385, 5222118.933436], [4652633.45115, 5222074.372674], [4652669.098607, 5222030.240749], [4652681.692868, 5221996.606005], [4652682.547081, 5221973.897116], [4652695.568296, 5221928.908161], [4652675.078218, 5221871.279117], [4652675.50532, 5221859.924815], [4652687.245134, 5221848.99919], [4652722.037372, 5221827.576549], [4652745.516788, 5221805.725244], [4652745.516788, 5221805.725244], [4652745.516788, 5221805.725244], [4652879.561504, 5221856.284388], [4652890.447401, 5221868.067127], [4652892.796323, 5222106.939376], [4652900.267622, 5222209.559852], [4652900.267622, 5222209.559852], [4652871.66461, 5222367.670477], [4653191.648158, 5222595.837639], [4653328.691303, 5222566.9085], [4653408.739363, 5222547.193473], [4653420.052982, 5222547.621326], [4653593.827782, 5222747.505665], [4653618.159779, 5222702.939284], [4653629.473604, 5222703.3669], [4653662.563077, 5222727.360487], [4653673.450941, 5222739.143484], [4653776.127605, 5222720.280099], [4653832.696927, 5222722.417105], [4653877.100913, 5222746.837374], [4653792.367493, 5222891.467896], [4654016.521129, 5222956.792324], [4654442.634711, 5223075.217678], [4654662.280915, 5222958.407377], [4654710.086505, 5222891.978267], [4655005.103986, 5222880.346779], [4655016.41816, 5222880.772748], [4655125.88259, 5222680.204446], [4655290.214715, 5222527.188284], [4655381.148939, 5222519.237281], [4655381.148939, 5222519.237281], [4655596.534717, 5222515.963738], [4656125.116508, 5222012.749434], [4656147.74301, 5222013.598497], [4656285.616145, 5221961.917695], [4656346.086558, 5221554.851566], [4656346.086558, 5221554.851566], [4656358.244617, 5221532.567223], [4656368.810729, 5221248.714623], [4656440.065229, 5221160.428307], [4656499.255141, 5220787.454971], [4656624.52987, 5220769.411072], [4656835.234449, 5220890.996177], [4657298.184125, 5220931.058955], [4657513.535078, 5220927.74042], [4657804.334457, 5220722.587454], [4657972.796439, 5220456.020221], [4657973.637692, 5220433.313941], [4657952.697194, 5220387.057187], [4657969.056158, 5220251.243488], [4658210.030769, 5219555.40558], [4658350.798225, 5219424.241673], [4658409.870185, 5219358.238004], [4658422.440445, 5219324.603916], [4658618.9352, 5218911.336196], [4658655.802218, 5218833.140492], [4658705.656569, 5218709.961674], [4658729.953914, 5218665.399379], [4659225.064359, 5218138.232586], [4659215.012172, 5218103.760622], [4659197.840483, 5217955.364572], [4659209.987012, 5217933.084438], [4659234.279892, 5217888.524271], [4659247.682798, 5217832.193683], [4659328.096593, 5217494.216581], [4659339.823481, 5217483.287068], [4659748.574834, 5217146.149498], [4659888.03077, 5217049.040954], [4660013.251342, 5217030.956525], [4660216.790132, 5217038.50341], [4660427.007172, 5216864.45808], [4660439.5667, 5216830.829613], [4660549.260885, 5216618.968196], [4660573.543986, 5216574.410272], [4661965.499392, 5216284.924361], [4662102.429341, 5216255.881364], [4662092.783546, 5216210.070363], [4662093.614127, 5216187.373353], [4662073.907514, 5216107.100602], [4662074.738121, 5216084.40384], [4662074.738121, 5216084.40384], [4662063.846666, 5216072.638644], [4662198.697528, 5216100.336538], [4662209.589187, 5216112.10162], [4662220.896003, 5216112.518284], [4662254.816462, 5216113.768194], [4662358.652744, 5216060.77519], [4662358.652744, 5216060.77519], [4662381.681217, 5216050.259772], [4662404.294738, 5216051.092661], [4662404.709642, 5216039.744308], [4662382.096148, 5216038.911422], [4662382.096148, 5216038.911422], [4662382.096148, 5216038.911422], [4662405.954344, 5216005.699328], [4662406.369241, 5215994.351028], [4662406.369241, 5215994.351028], [4662418.5057, 5215972.070882], [4662430.227235, 5215961.139019], [4662430.227235, 5215961.139019], [4662430.227235, 5215961.139019], [4662454.08506, 5215927.927057], [4662477.113109, 5215917.411534], [4662477.527913, 5215906.063332], [4662477.942715, 5215894.715143], [4662477.942715, 5215894.715143], [4662581.360733, 5215853.068868], [4662592.667277, 5215853.485061], [4662592.667277, 5215853.485061], [4662603.973823, 5215853.90124], [4662603.559175, 5215865.249392], [4662614.865736, 5215865.66556], [4662656.360698, 5215969.464142], [4662667.252805, 5215981.228552], [4663034.037868, 5215858.357843], [4663068.371747, 5215848.256564], [4663069.199928, 5215825.560223], [4663092.227107, 5215815.043266], [4663115.668268, 5215793.178133], [4663116.082297, 5215781.830016], [4663185.991104, 5215727.582654], [4663198.125407, 5215705.302029], [4663221.566053, 5215683.43686], [4663233.700213, 5215661.156286], [4663234.114088, 5215649.808314], [4663292.714947, 5215595.145437], [4663362.207667, 5215552.245572], [4663351.315133, 5215540.482477], [4663351.728856, 5215529.134638], [4663352.142578, 5215517.786811], [4663252.455866, 5215457.310214], [4663264.589642, 5215435.030112], [4663264.589642, 5215435.030112], [4663253.697361, 5215423.26706], [4663234.809815, 5215320.307617], [4663235.223657, 5215308.960049], [4663383.442245, 5215280.315948], [4663429.906828, 5215247.93399], [4663498.569326, 5215227.729485], [4663578.950843, 5215196.59199], [4663728.406571, 5215133.900428], [4663785.348748, 5215124.626634], [4663807.960336, 5215125.455979], [4663819.266133, 5215125.870632], [4663853.183532, 5215127.114508], [4663875.795139, 5215127.943691], [4663909.712562, 5215129.187365], [4663921.018372, 5215129.601896], [4663944.042975, 5215119.083506], [4663955.348777, 5215119.497994], [4664024.009382, 5215099.289839], [4664069.232536, 5215100.947322], [4664126.174271, 5215091.671475], [4664160.504351, 5215081.56685], [4664171.810129, 5215081.981076], [4664228.751676, 5215072.704618], [4664331.328718, 5215053.736663], [4664353.527761, 5215065.91206], [4664385.795323, 5215112.543647], [4664385.795323, 5215112.543647], [4664384.14552, 5215157.933511], [4664383.733066, 5215169.28101], [4664382.083231, 5215214.671142], [4664393.389189, 5215215.085115], [4664586.002934, 5215210.773003], [4664609.43926, 5215188.905315], [4664665.969021, 5215190.973669], [4664688.993029, 5215180.45336], [4664745.110753, 5215193.868796], [4664766.486686, 5215228.738635], [4664902.98261, 5215211.004664], [4664914.288614, 5215211.418012], [4664925.182806, 5215223.178962], [4664947.794848, 5215224.005593], [4664971.230413, 5215202.13694], [4664982.948156, 5215191.202609], [4665064.55996, 5215126.009711], [4665076.277502, 5215115.075342], [4665099.712505, 5215093.206593], [4665145.347582, 5215083.511431], [4665179.676708, 5215073.40305], [4665203.111377, 5215051.534125], [4665282.663679, 5215043.077201], [4665305.275361, 5215043.902941], [4665316.581204, 5215044.315791], [4665327.887049, 5215044.728627], [4665489.869126, 5214948.380213], [4665525.019584, 5214915.576024], [4665536.736349, 5214904.641288], [4665559.758776, 5214894.119092], [4665582.781153, 5214883.59685], [4665605.803481, 5214873.07456], [4665616.698195, 5214884.834314], [4665650.615252, 5214886.071657], [4665649.793418, 5214908.766269], [4665649.382499, 5214920.113595], [4665631.501635, 5215101.260172], [4665641.985685, 5215124.367758], [4665641.985685, 5215124.367758], [4665641.163785, 5215147.062933], [4665639.930923, 5215181.105797], [4665650.826019, 5215192.865908], [4665650.415073, 5215204.213571], [4665638.698048, 5215215.148781], [4665614.852924, 5215248.366903], [4665602.313784, 5215281.997603], [4665601.902772, 5215293.345367], [4665601.080744, 5215316.040935], [4665588.952489, 5215338.324019], [4665588.130422, 5215361.019692], [4665564.284738, 5215394.238169], [4665564.284738, 5215394.238169], [4665563.05153, 5215428.281889], [4665562.229384, 5215450.97777], [4665562.229384, 5215450.97777], [4665561.818308, 5215462.325731], [4665560.996152, 5215485.021692], [4665572.302545, 5215485.434277], [4665571.891478, 5215496.782279], [4665582.786831, 5215508.54287], [4665582.786831, 5215508.54287], [4665582.375775, 5215519.890901], [4665582.375775, 5215519.890901], [4665581.964717, 5215531.238945], [4665581.553657, 5215542.587003], [4665581.553657, 5215542.587003], [4665581.142596, 5215553.935073], [4665581.142596, 5215553.935073], [4665592.038023, 5215565.695727], [4665591.21592, 5215588.391939], [4665602.111398, 5215600.152626], [4665601.700356, 5215611.500767], [4665601.289312, 5215622.848922], [4665612.595873, 5215623.261472], [4665612.184841, 5215634.609642], [4665612.184841, 5215634.609642], [4665611.773808, 5215645.957825], [4665623.080397, 5215646.370364], [4665622.669375, 5215657.718562], [4665622.669375, 5215657.718562], [4665633.153959, 5215680.82753], [4665633.153959, 5215680.82753], [4665633.153959, 5215680.82753], [4665633.153959, 5215680.82753], [4665643.638591, 5215703.936544], [4665654.945253, 5215704.349051], [4665665.84094, 5215716.109816], [4665665.429963, 5215727.4581], [4665665.429963, 5215727.4581], [4665676.325689, 5215739.218884], [4665697.706279, 5215774.088802], [4665708.602098, 5215785.849609], [4665719.908863, 5215786.262046], [4665719.497944, 5215797.61042], [4665785.695278, 5215845.478432], [4665785.695278, 5215845.478432], [4665785.284432, 5215856.826882], [4665796.591289, 5215857.239234], [4665796.591289, 5215857.239234], [4665785.284432, 5215856.826882], [4665784.873584, 5215868.175345], [4665784.873584, 5215868.175345], [4665795.358781, 5215891.284668], [4665795.358781, 5215891.284668], [4665784.051884, 5215890.872312], [4665783.641031, 5215902.220815], [4665725.873732, 5215934.204389], [4665725.462806, 5215945.552938], [4665725.051878, 5215956.9015], [4665725.051878, 5215956.9015], [4665735.537015, 5215980.011103], [4665746.844014, 5215980.423526], [4665746.433108, 5215991.772132], [4665746.433108, 5215991.772132], [4665746.022201, 5216003.120752], [4665746.022201, 5216003.120752], [4665756.918333, 5216014.881799], [4665745.611292, 5216014.469384], [4665756.096538, 5216037.579108], [4665766.99272, 5216049.340189], [4665789.60689, 5216050.164959], [4665789.60689, 5216050.164959], [4665789.60689, 5216050.164959], [4665800.913978, 5216050.577325], [4665800.50313, 5216061.926019], [4665811.810233, 5216062.338372], [4665834.013633, 5216074.511751], [4665833.602823, 5216085.860477], [4665833.602823, 5216085.860477], [4665844.499158, 5216097.621534], [4665855.395521, 5216109.382593], [4665855.395521, 5216109.382593], [4665854.984733, 5216120.731363], [4665854.573943, 5216132.080146], [4665854.573943, 5216132.080146], [4665843.266753, 5216131.667837], [4665842.445142, 5216154.36544], [4665842.445142, 5216154.36544], [4665830.727106, 5216165.301934], [4665842.034334, 5216165.714261], [4665862.594867, 5216223.283199], [4665873.49139, 5216235.0444], [4666199.352221, 5216303.740059], [4666244.992285, 5216294.038544], [4666369.784195, 5216287.219037], [4666392.399047, 5216288.042408], [4666597.982577, 5216238.705206], [4666619.777582, 5216262.226028], [4666614.038985, 5216421.113586], [4666614.038985, 5216421.113586], [4666602.321454, 5216432.051371], [4666590.603896, 5216442.989152], [4666301.348975, 5216614.287456], [4666300.938671, 5216625.636867], [4666300.528366, 5216636.986291], [4666300.11806, 5216648.335729], [4666274.219642, 5216738.308029], [4666273.809294, 5216749.657585], [4666273.398945, 5216761.007154], [4666273.398945, 5216761.007154], [4666272.988594, 5216772.356736], [4666284.706925, 5216761.419007], [4666291.501256, 5216886.677025], [4666291.501256, 5216886.677025], [4666291.090915, 5216898.026758], [4666290.680572, 5216909.376505], [4666290.270228, 5216920.726265], [4666266.833142, 5216942.602082], [4666255.114559, 5216953.539986], [4666243.395948, 5216964.477887], [4666232.087731, 5216964.065965], [4666220.779515, 5216963.65403], [4666220.779515, 5216963.65403], [4666220.369082, 5216975.003848], [4666208.650406, 5216985.941727], [4666207.829505, 5217008.641426], [4666207.008597, 5217031.341179], [4666206.598141, 5217042.691076], [4666206.187684, 5217054.040986], [4666194.058416, 5217076.328868], [4666193.237463, 5217099.028779], [4666193.237463, 5217099.028779], [4666202.493495, 5217156.19078], [4666213.391478, 5217167.952802], [4666212.570554, 5217190.652934], [4666212.16009, 5217202.00302], [4666223.058136, 5217213.765089], [4666233.545767, 5217236.877291], [4666254.110753, 5217294.452035], [4666265.008955, 5217306.214176], [4666275.496782, 5217329.326564], [4666275.496782, 5217329.326564], [4666275.08638, 5217340.676821], [4666275.08638, 5217340.676821], [4666274.675976, 5217352.027091], [4666274.26557, 5217363.377375], [4666296.062204, 5217386.901793], [4666295.65182, 5217398.25212], [4666339.245458, 5217445.301054], [4666339.245458, 5217445.301054], [4666430.536363, 5217425.894602], [4666430.946588, 5217414.54423], [4666546.904975, 5217339.20854], [4666558.21367, 5217339.62012], [4666659.991989, 5217343.323731], [4666670.890768, 5217355.085487], [4666692.688408, 5217378.609009], [4666703.177371, 5217401.721145], [4666713.666383, 5217424.833327], [4666713.256495, 5217436.183739], [4666724.807305, 5217743.472788], [4666746.196053, 5217778.348008], [4666757.09542, 5217790.110227], [4666778.894235, 5217813.634673], [4666957.794752, 5217876.969257], [4666992.132476, 5217866.851668], [4667003.441841, 5217867.262764], [4667003.441841, 5217867.262764], [4667014.751208, 5217867.673847], [4667026.470132, 5217856.733962], [4667120.22055, 5217769.214763], [4667131.529811, 5217769.625696], [4667301.98735, 5217753.086341], [4667313.296609, 5217753.497055], [4667291.08732, 5217741.324771], [4667280.187317, 5217729.563205], [4667325.424243, 5217731.206073], [4667336.733479, 5217731.616757], [4667467.94522, 5217861.40404], [4667467.94522, 5217861.40404], [4667467.94522, 5217861.40404], [4667467.536192, 5217872.755043], [4667467.127163, 5217884.106058], [4667477.618557, 5217907.218661], [4667483.201769, 5218066.545226], [4667493.693386, 5218089.658263], [4667514.676766, 5218135.884476], [4667514.267768, 5218147.235808], [4667546.970136, 5218182.521348], [4667568.77185, 5218206.045057], [4667568.362909, 5218217.396478], [4667590.164755, 5218240.920228], [4667623.276605, 5218264.854382], [4667645.078696, 5218288.378133], [4667812.684512, 5218351.289886], [4667835.304554, 5218352.110188], [4668039.701997, 5218336.787216], [4668051.012021, 5218337.1971], [4668107.562168, 5218339.246318], [4668107.970475, 5218327.894701], [4668153.618819, 5218318.182215], [4668176.64707, 5218307.650094], [4668245.323392, 5218287.405016], [4668268.351475, 5218276.872696], [4668359.23932, 5218268.797579], [4668381.043319, 5218292.319715], [4668391.945359, 5218304.080788], [4668391.537394, 5218315.432403], [4668410.893894, 5218407.064744], [4668410.485941, 5218418.416483], [4668362.389238, 5218496.24107], [4668361.573198, 5218518.944765], [4668459.286623, 5218636.149337], [4668481.499577, 5218648.320161], [4668514.615191, 5218672.252359], [4668525.925661, 5218672.661705], [4668548.13879, 5218684.832426], [4668570.351979, 5218697.003112], [4668660.02069, 5218722.981222], [4668660.428374, 5218711.629097], [4668705.670503, 5218713.265715], [4668716.98104, 5218713.674836], [4668728.699178, 5218702.731822], [4668751.320232, 5218703.549993], [4668786.066886, 5218682.072931], [4668797.377393, 5218682.481952], [4668843.841815, 5218650.061654], [4668866.870195, 5218639.527479], [4668900.801591, 5218640.7542], [4668923.015167, 5218652.924013], [4668944.414124, 5218687.797998], [4668955.317324, 5218699.558955], [4668962.961965, 5218802.137521], [4668962.961965, 5218802.137521], [4668939.430309, 5219142.302316], [4668949.926623, 5219165.416539], [4668994.35637, 5219189.757347], [4669004.852868, 5219212.871631], [4669169.634925, 5219355.236544], [4669224.970457, 5219391.338408], [4669255.648339, 5219483.388349], [4669255.241295, 5219494.741446], [4669266.552814, 5219495.149981], [4669288.361844, 5219518.673256], [4669398.222387, 5219613.583265], [4669453.153489, 5219661.038178], [4669741.974844, 5219819.244756], [4669741.568349, 5219830.598298], [4669773.878417, 5219877.23653], [4669784.783992, 5219888.998095], [4669782.751725, 5219945.766375], [4669759.314544, 5219967.657845], [4669735.877256, 5219989.549302], [4669735.470737, 5220000.903046], [4669982.651511, 5220373.611824], [4670005.683014, 5220363.073088], [4670335.728043, 5220636.450069], [4670355.918974, 5220705.392381], [4670342.17074, 5220773.113147], [4670339.329637, 5220852.596551], [4670339.329637, 5220852.596551], [4670338.517879, 5220875.306216], [4670404.368487, 5220934.524649], [4670483.967636, 5220926.020482], [4670674.267216, 5220989.715864], [4670684.769696, 5221012.832895], [4670683.958734, 5221035.543006], [4670734.039365, 5221219.260647], [4671091.596788, 5221675.550561], [4671112.605249, 5221721.78721], [4671121.489446, 5221790.329524], [4671092.784559, 5221959.858026], [4671091.974396, 5221982.570463], [4671089.94896, 5222039.351792], [4671089.543868, 5222050.708098], [4671109.742925, 5222119.659371], [4671197.426743, 5222202.406637], [4671228.536937, 5222283.121858], [4671679.908291, 5222970.247], [4671742.950846, 5223108.973117], [4671742.950846, 5223108.973117], [4671742.142022, 5223131.688407], [4671813.672339, 5223350.327514], [4671936.535532, 5223400.22274], [4671936.535532, 5223400.22274], [4671936.535532, 5223400.22274], [4672003.625866, 5223425.372677], [4672025.854693, 5223437.541917], [4672025.854693, 5223437.541917], [4671871.054905, 5223966.51617], [4671811.234157, 5224055.356556], [4671810.425319, 5224078.074107], [4671808.403197, 5224134.868222], [4671796.277021, 5224157.180038], [4671633.383683, 5224276.443962], [4671587.30451, 5224297.537336], [4671562.241147, 5224364.879317], [4671493.121442, 5224396.51904], [4671470.486299, 5224395.706379], [4671447.041392, 5224417.611954], [4671434.104183, 5224462.642307], [4671388.428649, 5224472.375834], [4671330.220268, 5224515.780363], [4671330.220268, 5224515.780363], [4671226.740389, 5224557.558207], [4671202.889332, 5224590.822838], [4671108.699366, 5224689.803435], [4671072.718903, 5224745.380348], [4671049.272218, 5224767.285657], [4671036.738009, 5224800.95743], [4671018.122042, 5225005.025022], [4671006.398318, 5225015.977891], [4670970.415951, 5225071.556233], [4670957.881017, 5225105.228945], [4670957.069939, 5225127.94883], [4670967.982807, 5225139.715817], [4670756.541737, 5225348.228648], [4670722.179985, 5225358.366913], [4670568.947238, 5225523.474753], [4670567.729104, 5225557.555981], [4670574.98756, 5225671.568498], [4670585.900531, 5225683.336606], [4670606.102489, 5225752.315381], [4670613.767478, 5225854.969428], [4670613.361457, 5225866.330222], [4670633.157946, 5225946.671178], [4670654.98467, 5225970.207973], [4670687.319013, 5226016.874169], [4670718.030005, 5226108.984785], [4670724.884492, 5226234.365112], [4670746.712086, 5226257.902443], [4670777.830215, 5226338.653865], [4670772.959673, 5226474.991371], [4670783.062028, 5226509.483427], [4670781.4385, 5226554.929861], [4670843.6776, 5226716.438216], [4670897.844438, 5226786.645914], [4670908.759052, 5226798.415095], [4670919.267948, 5226821.546237], [4670918.862202, 5226832.90821], [4670918.050705, 5226855.632195], [4670917.644955, 5226866.994207], [4670917.239202, 5226878.356233], [4670905.107188, 5226900.673074], [4670910.746955, 5227060.150484], [4670907.906471, 5227139.686553], [4670894.150839, 5227207.453558], [4670901.819464, 5227310.123209], [4670717.841536, 5227383.142616], [4670602.600092, 5227435.879802], [4670609.047069, 5227572.640448], [4670608.640881, 5227584.003284], [4670493.746569, 5227943.951029], [4670482.424859, 5227943.54317], [4670353.820842, 5228052.688913], [4670283.856786, 5228107.057486], [4670272.12826, 5228118.012799], [4670237.349204, 5228139.515242], [4670237.349204, 5228139.515242], [4670225.620584, 5228150.47053], [4670337.558052, 5228507.234725], [4670286.981944, 5228653.334196], [4670540.89871, 5228844.546097], [4670572.42897, 5228913.955959], [4670842.507943, 5229287.817553], [4670829.154161, 5229344.234604], [4670833.980142, 5229526.483242], [4670833.574039, 5229537.848423], [4670819.001407, 5229628.362745], [4670841.648915, 5229629.177957], [4670942.344831, 5229666.941732], [4670984.798528, 5229748.129359], [4671136.029639, 5229958.412787], [4671192.650542, 5229960.448963], [4671351.564147, 5230273.435567], [4671350.347484, 5230307.533964], [4671816.24654, 5230916.085954], [4671838.492283, 5230928.26594], [4671838.492283, 5230928.26594], [4671894.714347, 5230941.665298], [4671893.094479, 5230987.133241], [4671904.015, 5230998.90671], [4671969.943576, 5231058.180478], [4672013.221693, 5231116.641568], [4672119.199626, 5231006.626676], [4672223.961395, 5230930.712622], [4672376.044846, 5230799.587154], [4672500.218996, 5230815.417612], [4672521.252849, 5230861.696585], [4672543.499445, 5230873.874865], [4672543.095265, 5230885.241811], [4672554.420682, 5230885.647468], [4672564.937789, 5230908.78705], [4672564.129472, 5230931.521043], [4672595.681154, 5231000.940239], [4672605.39024, 5231046.814339], [4672615.907637, 5231069.954268], [4672615.099412, 5231092.688654], [4672647.460124, 5231139.374334], [4672657.573649, 5231173.881749], [4672679.821151, 5231186.060145], [4672711.374467, 5231255.480878], [4672721.892338, 5231278.621216], [4672732.814251, 5231290.39414], [4672922.932486, 5231365.490338], [4672955.699373, 5231400.808786], [4673098.095611, 5231542.487913], [4673098.095611, 5231542.487913], [4673108.211167, 5231576.996391], [4673118.730351, 5231600.137121], [4673104.98257, 5231667.939458], [4673090.830969, 5231747.110272], [4673095.699804, 5231929.405585], [4673095.296187, 5231940.77384], [4673182.681944, 5232034.960808], [4673252.660255, 5231980.548787], [4673322.63777, 5231926.13652], [4673335.174488, 5231892.436597], [4673346.904494, 5231881.473174], [4673415.671069, 5231861.165246], [4673438.3244, 5231861.974628], [4673562.917833, 5231866.42526]]]}"
	end
end
