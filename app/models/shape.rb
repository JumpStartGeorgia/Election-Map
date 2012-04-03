class Shape < ActiveRecord::Base
  translates :name
  has_ancestry
  require 'csv'

  has_many :shape_translations, :dependent => :destroy
  belongs_to :shape_type
  accepts_nested_attributes_for :shape_translations
  attr_accessible :shape_type_id, :common_id, :common_name, :geometry, :shape_translations_attributes
  attr_accessor :locale

  validates :shape_type_id, :common_id, :geometry, :presence => true
  
  scope :l10n , joins(:shape_translations).where('locale = ?',I18n.locale)
  scope :by_name , order('name').l10n

	# get the name of the shape (common_id)
	def self.get_shape_name(shape_id)
		return shape_id.nil? ? "" : select("common_id").where(:id => shape_id).first
	end

	# get the name of the shape (common_id)
	def self.get_shape_no_geometry(shape_id)
		return shape_id.nil? ? "" : select("id, shape_type_id, common_id, common_name, ancestry").where(:id => shape_id).first
	end

		# create the properly formatted json string
		def self.build_json(shapes, indicator_id)
			json = ''
			if !shapes.nil? && shapes.length > 0
				json = '{ "type": "FeatureCollection","features": ['
				shapes.each_with_index do |shape, i|
					json << '{ "type": "Feature", "geometry": '
					json << shape.geometry
					json << ', "properties": {'
					json << '"id":"'
					json << shape.id.to_s
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
						(!data.nil? && data.length == 1) ? json << data[0].value : json << "No Data"
					end
					json << '"}}'
					json << ',' if i < shapes.length-1 # do not add comma for the last shape
				end
				json << ']}'
			end
			return json
		end

    def self.csv_header
      "Event, Shape Type, Parent ID, Common ID, Common Name, Geometry".split(",")
    end

    def self.build_from_csv(file, deleteExistingRecord)
	    infile = file.read
	    n, msg = 0, ""

			Shape.transaction do
			  CSV.parse(infile, :col_sep => "\t") do |row|

			    n += 1
			    # SKIP: header i.e. first row OR blank row
			    next if n == 1 or row.join.blank?

      		# get the event id
      		event = Event.find_by_name(row[0].strip)
      		# get the shape type id
      		shape_type = ShapeType.find_by_name(row[1].strip)

      		if event.nil? || shape_type.nil?
      logger.debug "event or shape type was not found"		
      		  msg = "Row #{n} - The event or shape type was not found."
			      raise ActiveRecord::Rollback
            return msg
      		else
    logger.debug "found event and shape type, get root shape"
            # get the root shape
            root = Shape.where(:id => event.shape_id).first
        
            # if the root shape already exists and deleteExistingRecord is true, delete the shape
						#  if this is the root record (row[2] is nil)
            if !root.nil? && deleteExistingRecord && (row[2].nil? || row[2].strip.length == 0)
	logger.debug "+++ deleting existing root shape"
                Shape.destroy(root.id)
                root = nil
            end

            if root.nil?
    logger.debug "root does not exist"
              if row[2].nil? || row[2].strip.length == 0
                # no root exists in db, but this is the root, so add it
    logger.debug "adding root shape"
                shape = Shape.create :shape_type_id => shape_type.id, :common_id => row[3].strip, 
									:common_name => row[4].strip, :geometry => row[5].strip
                if shape.valid?
                  # update the event to have this as the root
    logger.debug "updating event to map to this root shape"
                  success = event.update_attribute :shape_id, shape.id
                  if !success
                    # could not update event record
              		  msg = "Row #{n} - The event could not be updated to indicate this row is the root."
    logger.debug "event could not be updated to indicate this is the root"
        			      raise ActiveRecord::Rollback
              		  return msg
                  end
                else
                  # could not create shape
            		  msg = "Row #{n} - The record for this root row could not be saved."
    logger.debug "root row could not be saved"
      			      raise ActiveRecord::Rollback
            		  return msg
                end
              else
                # no root exists and this row is not root -> stop
          		  msg = "Row #{n} - The root shape for this event was not found."
      logger.debug "root shape for this event was not found"
                raise ActiveRecord::Rollback
                return msg
              end
            else
              # found root, continue
              # if this is row 2, see if this row is also a root and the same
              if n==2 && row[2].nil? && root.shape_type_id == shape_type.id && root.common_id == row[3].strip
          		  msg = "Row #{n} - This root record already exists."
        logger.debug "**root record already exists!"
                raise ActiveRecord::Rollback
                return msg
              else
                # only conintue if all values are present
                if row[2].nil? || row[3].nil? || row[5].nil?
            		  msg = "Row #{n} - Data is missing that is required to save record."
      logger.debug "**missing data in row"
                  raise ActiveRecord::Rollback
                  return msg
                else
      logger.debug "chekcing if row already in db"
                  alreadyExists = root.descendants.where ({:shape_type_id => shape_type.id, 
											:common_id => row[3].strip, :common_name => row[4].strip, :geometry => row[5].strip})

                  # if the shape already exists and deleteExistingRecord is true, delete the sha[e]
                  if !alreadyExists.nil? && alreadyExists.length > 0 && deleteExistingRecord
      	logger.debug "+++ deleting existing shape"
                      Shape.destroy (alreadyExists[0].id)
                      alreadyExists = nil
                  end

                  if alreadyExists.nil? || alreadyExists.length == 0
      logger.debug "row is not in db, get parent shape type"
                    # record does not exist yet
                    # find parent shape type so we can find parent shape
                    parent_shape_type = shape_type.parent
                    if parent_shape_type.nil?
                      # did not find parent shape type
                		  msg = "Row #{n} - The parent shape type could not be found."
          logger.debug "**could not find parent shape type"
                      raise ActiveRecord::Rollback
                      return msg
                    else
        logger.debug "getting parent shape"
                      # check if the root has descendants
                      # have to check the root object by iteself and then check for through the descendants
                      parentRoot = root.shape_type_id == parent_shape_type.id && root.common_id == row[2].strip ? root : nil
                      if root.has_children?
                        parentChild = root.descendants.where ({:shape_type_id => parent_shape_type.id, :common_id => row[2].strip})
                      end
                  
                      # see if a parent node was found
                      if (parentRoot.nil?) && (parentChild.nil? || parentChild.length == 0)
          logger.debug "no parent shape found"
                        # no parent found
                        parent = nil
                      elsif !parentRoot.nil?
          logger.debug "parent shape is root"
                        parent = parentRoot
                      elsif !parentChild.nil? && parentChild.length > 0
          logger.debug "parent is a child node"
                        parent = parentChild.first
                      end
          logger.debug "parent = #{parent}"
                      if parent.nil?
                        # did not find parent shape
                  		  msg = "Row #{n} - The parent shape could not be found."
            logger.debug "**could not find parent shape"
                        raise ActiveRecord::Rollback
                        return msg
                      else
                        # found parent, add child
        logger.debug "found parent, saving this row"
                        shape = parent.children.create :shape_type_id => shape_type.id, :common_id => row[3].strip, 
													:common_name => row[4].strip, :geometry => row[5].strip

                        if !shape.valid?
                          # could not create shape
                    		  msg = "Row #{n} - The record for this row could not be saved."
            logger.debug "row could not be saved"
                          raise ActiveRecord::Rollback
                          return msg
                        end
                      end
                    end
                  else
                    # record already exists
              		  msg = "Row #{n} - This record already exists."
            logger.debug "**record already exists!"
                    raise ActiveRecord::Rollback
                    return msg
                  end
                end
              end
            end  
          end  
        end
      end 
  logger.debug "procssed #{n} rows in CSV file"
      return msg 
    end    
end
