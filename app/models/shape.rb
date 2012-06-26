class Shape < ActiveRecord::Base
  translates :common_id, :common_name
  has_ancestry
  require 'csv'

  has_many :shape_translations, :dependent => :destroy
  belongs_to :shape_type
  accepts_nested_attributes_for :shape_translations
  attr_accessible :shape_type_id, :geometry, :shape_translations_attributes
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
		return shape_id.nil? ? "" : select("shapes.id, shape_type_id, common_id, common_name, ancestry")
					.joins(:shape_translations)
					.where(:shapes => {:id => shape_id}, :shape_translations => {:locale => I18n.locale}).first
	end

	# get the list of shapes for data download
	def self.get_shapes_for_download(shape_id, shape_type_id)
		return shape_id.nil? || shape_type_id.nil? ? nil : select("shapes.id, shape_type_id, common_id, common_name, ancestry")
					.joins(:shape_translations)
					.where("shapes.shape_type_id = :shape_type_id and shape_translations.locale = :locale and ((shapes.shape_type_id = 1 and shapes.id = :shape_id) or (shapes.shape_type_id = 2 and shapes.ancestry = :shape_id) or (shapes.ancestry like :shape_id_like))", 
			:shape_id => shape_id, :shape_type_id => shape_type_id, :shape_id_like => "%/#{shape_id}", :locale => I18n.locale)
	end

	# need this so can access ActionView::Helpers::NumberHelper helpers to format numbers in build_json
	def self.helpers
		ActionController::Base.helpers
	end
	# need this to access the number_format value in build_json
  def number_format
    attributes['number_format']
  end

	# create the properly formatted json string
	def self.build_json(shapes, indicator_id=nil)
		json = ''
		if !shapes.nil? && shapes.length > 0
			json = '{ "type": "FeatureCollection","features": ['
			shapes.each_with_index do |shape, i|
				json << '{ "type": "Feature", "geometry": '
				json << shape.geometry
				json << ', "properties": {'
				json << '"id":"'
				json << shape.id.to_s
				json << '", "parent_id":"'
				shape.parent_id.nil? ? json << "" : json << shape.parent_id.to_s
				json << '", "common_id":"'
				json << shape.common_id
				json << '", "common_name":"'
			  json << shape.common_name if !shape.common_name.nil?
				json << '", "has_children":"'
				json << shape.has_children?.to_s
				json << '", "shape_type_id":"'
				json << shape.shape_type_id.to_s
				json << '", "value":"'
				if !indicator_id.nil?
					data = Datum.get_data_for_shape(shape.id, indicator_id)
					(!data.nil? && data.length == 1 && !data[0].value.nil? && data[0].value.downcase != "null") ? json << data[0].value : json << I18n.t('app.msgs.no_data')
				end
				json << '"}}'
				json << ',' if i < shapes.length-1 # do not add comma for the last shape
			end
			json << ']}'
		end
		return json
	end

	# create the properly formatted json string
	def self.build_summary_json(shapes, event_id, indicator_type_id)
		json = ''
		if !shapes.nil? && !shapes.empty? && !event_id.nil? && !indicator_type_id.nil?
			json = '{ "type": "FeatureCollection","features": ['
			shapes.each_with_index do |shape, i|
				json << '{ "type": "Feature", "geometry": '
				json << shape.geometry
				json << ', "properties": {'
				json << '"id":"'
				json << shape.id.to_s
				json << '", "parent_id":"'
				shape.parent_id.nil? ? json << "" : json << shape.parent_id.to_s
				json << '", "common_id":"'
				json << shape.common_id
				json << '", "common_name":"'
			  json << shape.common_name if !shape.common_name.nil?
				json << '", "has_children":"'
				json << shape.has_children?.to_s
				json << '", "shape_type_id":"'
				json << shape.shape_type_id.to_s

				data = Datum.get_summary_data_for_shape(shape.id, event_id, indicator_type_id)
				if !data.nil? && data.length == 1 && !data[0].value.nil? && data[0].value.downcase != "null"
					json << '", "data_value":"'
					json << data[0].value
					json << '", "value":"'
					json << data[0].attributes["indicator_name"]
					json << '", "color":"'
					json << data[0].attributes["color"] if !data[0].attributes["color"].nil? 
					json << '", "number_format":"'
					json << data[0].attributes["number_format"] if !data[0].attributes["number_format"].nil? 
				else
					json << '", "data_value":"'
					json << I18n.t('app.msgs.no_data')
					json << '", "value":"'
					json << I18n.t('app.msgs.no_data')
					json << '", "color":"'
					json << '", "number_format":"'
				end

				json << '"}}'
				json << ',' if i < shapes.length-1 # do not add comma for the last shape
			end
			json << ']}'
		end
		return json
	end



  def self.csv_header
    "Event, Shape Type, Parent ID, Parent Name, Common ID, Common Name, Geometry".split(",")
  end

    def self.build_from_csv(file, deleteExistingRecord)
	    infile = file.read
	    n, msg = 0, ""
			old_root_id = nil
			

			Shape.transaction do
			  CSV.parse(infile, :col_sep => "\t") do |row|

			    n += 1
			    # SKIP: header i.e. first row OR blank row
			    next if n == 1 or row.join.blank?
    logger.debug "++++processing row #{n}"		

	        if row[0].nil? || row[0].strip.length == 0 || row[1].nil? || row[1].strip.length == 0
    logger.debug "++++event or shape type was not found in spreadsheet"
      		  msg = I18n.t('models.shape.msgs.no_event_shape_spreadsheet', :row_num => n)
			      raise ActiveRecord::Rollback
            return msg
					else
		    		# get the event id
		    		event = Event.find_by_name(row[0].strip)
		    		# get the shape type id
		    		shape_type = ShapeType.find_by_name_singular(row[1].strip)

		    		if event.nil? || shape_type.nil?
		  logger.debug "++++event or shape type was not found"		
		    		  msg = I18n.t('models.shape.msgs.no_event_shape_db', :row_num => n)
					    raise ActiveRecord::Rollback
		          return msg
		    		else
		  logger.debug "++++found event and shape type, get root shape"
		          # get the root shape
		          root = Shape.joins(:shape_translations)
		                  .where(:shapes => {:id => event.shape_id}, :shape_translations => {:locale => 'en'}).first
		      
		          # if the root shape already exists and deleteExistingRecord is true, delete the shape
							#  if this is the root record (row[2] is nil)
		          if !root.nil? && deleteExistingRecord && (row[2].nil? || row[2].strip.length == 0)
		logger.debug "+++++++ deleting existing root shape and all of its descendants"
									# save the existing root id so at the end all events with this root can be updated
									old_root_id = root.id
									# destroy the shapes
		              Shape.destroy_all(["id in (?)", root.subtree_ids])
		              root = nil
		          end

		          if root.nil?
		  logger.debug "++++root does not exist"
		            if row[2].nil? || row[2].strip.length == 0
		              # no root exists in db, but this is the root, so add it
		  logger.debug "++++adding root shape"
                  shape = Shape.create :shape_type_id => shape_type.id, :geometry => row[6].strip
									# add translations
									I18n.available_locales.each do |locale|
										shape.shape_translations.create(:locale => locale, :common_id => row[4].strip, :common_name => row[5].strip)
									end

		              if shape.valid?
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
		          else
		    logger.debug "++++root already exists"
		            # found root, continue
	              # only conintue if all values are present
	              if row[2].nil? || row[3].nil? || row[4].nil? || row[5].nil? || row[6].nil?
	          		  msg = I18n.t('models.shape.msgs.missing_data_spreadsheet', :row_num => n)
	    logger.debug "++++**missing data in row"
	                raise ActiveRecord::Rollback
	                return msg
			          else
			            # if this is row 2, see if this row is also a root and the same
				          if n==2 && row[2].nil? && root.shape_type_id == shape_type.id && 
											root.common_id == row[4].strip && root.common_name == row[5].strip
				      		  msg = I18n.t('models.shape.msgs.root_already_exists', :row_num => n)
				  logger.debug "++++**root record already exists!"
				            raise ActiveRecord::Rollback
				            return msg
		              else
		    logger.debug "++++chekcing if row already in db"
		                alreadyExists = root.descendants.joins(:shape_translations)
		                  .where(:shapes => {:shape_type_id => shape_type.id, :geometry => row[6].strip}, 
		                    :shape_translations => {:locale => 'en', :common_id => row[4].strip, :common_name => row[5].strip})

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
		                    # check if the root has descendants
		                    # have to check the root object by iteself and then check for through the descendants
		                    parentRoot = root.shape_type_id == parent_shape_type.id && 
		                      root.common_id == row[2].strip && root.common_name == row[3].strip ? root : nil
		                    if root.has_children?
		                      parentChild = root.descendants.joins(:shape_translations)
		                        .where(:shapes => {:shape_type_id => parent_shape_type.id}, 
		                        :shape_translations => {:locale => 'en', :common_id => row[2].strip, :common_name => row[3].strip})
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
		                    if parent.nil?
		                      # did not find parent shape
			              		  msg = I18n.t('models.shape.msgs.parent_shape_not_found', :row_num => n)
		          logger.debug "++++**could not find parent shape"
		                      raise ActiveRecord::Rollback
		                      return msg
		                    else
		                      # found parent, add child
		      logger.debug "++++found parent, saving this row"
		                      shape = parent.children.create :shape_type_id => shape_type.id, :geometry => row[6].strip
													# add translations
													I18n.available_locales.each do |locale|
														shape.shape_translations.create(:locale => locale, :common_id => row[4].strip, :common_name => row[5].strip)
													end

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
        end

  logger.debug "++++updating ka records with ka text in shape_names"
				# ka translation is hardcoded as en in the code above
				# update all ka records with the apropriate ka translation
				# update common ids
				ActiveRecord::Base.connection.execute("update shape_translations as st, shape_names as sn set st.common_id = sn.ka where st.locale = 'ka' and st.common_id = sn.en")
				# update common names
				ActiveRecord::Base.connection.execute("update shape_translations as st, shape_names as sn set st.common_name = sn.ka where st.locale = 'ka' and st.common_name = sn.en")

			end 
  logger.debug "++++procssed #{n} rows in CSV file"
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
		          if !Shape.destroy_all(["id in (:shape_ids) and shape_type_id in (:shape_type_ids)", 
								:shape_ids => event.shape.subtree_ids, :shape_type_ids => shape_type.subtree_ids])

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
end
