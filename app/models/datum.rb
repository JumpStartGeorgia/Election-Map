class Datum < ActiveRecord::Base
  belongs_to :indicator

  attr_accessible :indicator_id, :common_id, :common_name, :value

  validates :indicator_id, :common_id, :common_name, :value, :presence => true


	# get the data value for a specific shape
	def self.get_data_for_shape(shape_id, indicator_id)
		if (indicator_id.nil? || shape_id.nil?)
			return nil		
		else
			sql = "SELECT d.id, d.value, i.number_format FROM data as d "
			sql << "inner join indicators as i on d.indicator_id = i.id "
			sql << "left join shapes as s on d.common_id = s.common_id and d.common_name = s.common_name and i.shape_type_id = s.shape_type_id "
			sql << "WHERE i.id = :indicator_id AND s.id = :shape_id"
		
			find_by_sql([sql, :indicator_id => indicator_id, :shape_id => shape_id])
		end
	end

  def self.csv_header
    "Event, Shape Type, Common ID, Common Name, Indicator, Value, Indicator, Value".split(",")
  end

  def self.build_from_csv(file, deleteExistingRecord)
    infile = file.read
    n, msg = 0, ""

		Datum.transaction do
		  CSV.parse(infile) do |row|
		    n += 1
		    # SKIP: header i.e. first row OR blank row
		    next if n == 1 or row.join.blank?
	logger.debug "++++processing row #{n}"				

        if row[0].nil? || row[0].strip.length == 0 || row[1].nil? || row[1].strip.length == 0
  logger.debug "++++event or shape type was not found in spreadsheet"
    		  msg = I18n.t('models.datum.msgs.no_event_shape_spreadsheet', :row_num => n)
		      raise ActiveRecord::Rollback
          return msg
				else
					# get the event id
					event = Event.find_by_name(row[0].strip)
					# get the shape type id
					shape_type = ShapeType.find_by_name(row[1].strip)

					if event.nil? || shape_type.nil?
			logger.debug "++++event or shape type was not found"				
		  		  msg = I18n.t('models.datum.msgs.no_event_shape_db', :row_num => n)
				    raise ActiveRecord::Rollback
		  		  return msg
					else
			logger.debug "++++event and shape found, procesing indicators"
						finishedIndicators = false
						i = 4 # where first indicator starts

						until finishedIndicators do
							if row[i].nil? || row[i+1].nil?
			logger.debug "++++found empty cells, stopping processing for row"
							  # found empty cell, stop
							  finishedIndicators = true
							else
		            # only conintue if required fields provided
		            if row[2].nil? || row[3].nil?
		        		  msg = I18n.t('models.datum.msgs.missing_data_spreadsheet', :row_num => n)
		  logger.debug "++++**missing data in row"
		              raise ActiveRecord::Rollback
		              return msg
		            else
									# see if indicator already exists for the provided event and shape_type
									indicator = Indicator.includes(:indicator_translations)
										.where('indicators.event_id = ? and indicators.shape_type_id = ? and indicator_translations.locale="en" and indicator_translations.name= ?', 
											event.id, shape_type.id, row[i].strip)
					
									if indicator.nil? || indicator.length == 0
					logger.debug "++++indicator was not found"
										msg = I18n.t('models.datum.msgs.indicator_not_found', :row_num => n)
										raise ActiveRecord::Rollback
										return msg
									else
					logger.debug "++++indicator found, checking if data exists"
										# check if data already exists
										alreadyExists = Datum.where(:indicator_id => indicator.first.id, 
											:common_id => row[2].nil? ? row[2] : row[2].strip, 
											:common_name => row[3].nil? ? row[3] : row[3].strip)
					
				            # if the datum already exists and deleteExistingRecord is true, delete the datum
				            if !alreadyExists.nil? && alreadyExists.length > 0 && deleteExistingRecord
					logger.debug "+++++++ deleting existing #{alreadyExists.length} datum records "
					              alreadyExists.each do |exists|
				                  Datum.destroy (exists.id)
                        end
				                alreadyExists = nil
				            end

										if alreadyExists.nil? || alreadyExists.length == 0
					logger.debug "++++data does not exist, save it"
											# populate record
											datum = Datum.new
											datum.indicator_id = indicator.first.id
											datum.common_id = row[2].nil? ? row[2] : row[2].strip
											datum.common_name = row[3].nil? ? row[3] : row[3].strip
											datum.value = row[i+1].nil? ? row[i+1] : row[i+1].strip

				logger.debug "++++saving record"
											if datum.valid?
												datum.save
											else
												# an error occurred, stop
										    msg = I18n.t('models.datum.msgs.not_valid', :row_num => n)
										    raise ActiveRecord::Rollback
										    return msg
											end

											i+=2 # move on to the next set of indicator/value pairs
										else
				logger.debug "++++**record already exists!"
											msg = I18n.t('models.datum.msgs.already_exists', :row_num => n)
											raise ActiveRecord::Rollback
											return msg
										end
									end
								end
							end
						end
					end
				end
			end
		end
  logger.debug "++++procssed #{n} rows in CSV file"
    return msg 
  end

end
