class Indicator < ActiveRecord::Base
  translates :name, :name_abbrv, :description
  require 'csv'

  has_many :indicator_translations, :dependent => :destroy
  has_many :indicator_scales, :dependent => :destroy
  has_many :data, :dependent => :destroy
  belongs_to :event
  belongs_to :shape_type
  accepts_nested_attributes_for :indicator_translations
  attr_accessible :event_id, :shape_type_id, :number_format, :indicator_translations_attributes
  attr_accessor :locale

  validates :event_id, :shape_type_id, :presence => true
  
  scope :l10n , joins(:indicator_translations).where('locale = ?',I18n.locale)
  scope :by_name , order('name').l10n


	# the shape_type has changed, get the indicator that 
  # matches the indicator from the last shape type
	def self.find_new_id(old_indicator, new_shape_type, locale)
		if (old_indicator.nil? || new_shape_type.nil? || locale.nil?)
			return nil		
		else
			sql = "select inew.* "
			sql << "from indicators as iold "
			sql << "inner join indicators as inew on iold.event_id = inew.event_id  "
			sql << "inner join indicator_translations as itold on iold.id = itold.indicator_id "
			sql << "inner join indicator_translations as itnew on inew.id = itnew.indicator_id and itold.name = itnew.name and itold.locale = itnew.locale "
			sql << "where iold.id = :old_indicator and inew.shape_type_id = :new_shape_type and itold.locale = :locale"
		
			find_by_sql([sql, :old_indicator => old_indicator, :new_shape_type => new_shape_type, :locale => locale])
		end
	end

  def self.csv_header
    "Event, Shape Type, en: Indicator Name, en: Indicator Abbrv, en: Indicator Description, ka: Indicator Name, ka: Indicator Abbrv, ka: Indicator Description, Number Format (optional, e.g., %), en: Scale Name, ka: Scale Name, Scale Color, en: Scale Name, ka: Scale Name, Scale Color".split(",")
  end

  def self.csv_change_name_header
    "Event, Shape Type, OLD en: Indicator Name, NEW en: Indicator Name, NEW en: Indicator Abbrv, NEW en: Indicator Description, NEW ka: Indicator Name, NEW ka: Indicator Abbrv, NEW ka: Indicator Description, Number Format (optional, e.g., %)".split(",")
  end

  def self.build_from_csv(file, deleteExistingRecord)
    infile = file.read
    n, msg = 0, ""
    index_first_scale = 9
    columns_per_scale = 3

		Indicator.transaction do
		  CSV.parse(infile) do |row|
        num_colors_found_for_indicator = 0 # record number of colors found

		    n += 1
		    # SKIP: header i.e. first row OR blank row
		    next if n == 1 or row.join.blank?
    logger.debug "++++processing row #{n}"		

        # if the event or shape type are not provided, stop
        if row[0].nil? || row[0].strip.length == 0 || row[1].nil? || row[1].strip.length == 0
  logger.debug "+++++++ event or shape type not provided"				
    		  msg = "Row #{n} - The event or shape type was not found in the spreadsheet."
  	      raise ActiveRecord::Rollback
    		  return msg
  			else
  				# get the event id
  				event = Event.find_by_name(row[0].strip)
  				# get the shape type id
  				shape_type = ShapeType.find_by_name(row[1].strip)

  				if event.nil? || shape_type.nil?
  	logger.debug "++++event or shape type was not found"				
      		  msg = "Row #{n} - The event or shape type was not found."
  		      raise ActiveRecord::Rollback
      		  return msg
  				else
            # only conintue if all values are present
            if row[2].nil? || row[3].nil? || row[4].nil? || row[5].nil? || row[6].nil? || row[7].nil?
        		  msg = "Row #{n} - Data is missing that is required to save record."
  logger.debug "+++++**missing data in row"
              raise ActiveRecord::Rollback
              return msg
            else
			logger.debug "++++found event and shape type, seeing if record already exists"
							# see if indicator already exists for the provided event and shape_type
							alreadyExists = Indicator.includes(:indicator_translations)
							  .where('indicators.event_id = ? and indicators.shape_type_id = ? and indicator_translations.locale="en" and indicator_translations.name= ?', 
							    event.id, shape_type.id, row[2].strip)
					
		          # if the indicator already exists and deleteExistingRecord is true, delete the indicator
		          if !alreadyExists.nil? && alreadyExists.length > 0 && deleteExistingRecord
		logger.debug "+++++++ deleting existing indicator"
		              Indicator.destroy (alreadyExists[0].id)
		              alreadyExists = nil
		          end
					
							if alreadyExists.nil? || alreadyExists.length == 0
			logger.debug "++++record does not exist, populate obj"
								# populate record
								ind = Indicator.new
								ind.event_id = event.id
								ind.shape_type_id = shape_type.id
								ind.number_format = row[8].strip if !row[8].nil? && row[8].strip.length > 0
							  # translations
								ind.indicator_translations.build(:locale => 'en', :name => row[2].strip, 
										:name_abbrv => row[3].strip, :description => row[4].strip)
								ind.indicator_translations.build(:locale => 'ka', :name => row[5].strip, 
										:name_abbrv => row[6].strip, :description => row[7].strip)
							  # scales
							  finishedScales = false # keep looping until find empty cell
							  i = index_first_scale # where first scale starts
							  until finishedScales do
							    if row[i].nil? || row[i+1].nil?
							      # found empty cell, stop
							      finishedScales = true
							    else
							      # found scale, add it
							      scale = ind.indicator_scales.build
		    					  scale.color = row[i+2].strip if (!row[i+2].nil? && row[i+2].strip.length > 0)
										scale.indicator_scale_translations.build(:locale => 'en', :name => row[i].strip)
										scale.indicator_scale_translations.build(:locale => 'ka', :name => row[i+1].strip)

		                # remember if a color was found
		                num_colors_found_for_indicator+=1 if (!row[i+2].nil? && row[i+2].strip.length > 0)

										i+=columns_per_scale # move on to the next set of indicator scales
							    end
							  end
							  # save if no scales provided 
							  #  or if scales color provided for all scales
							  #  or there were between 3 and 9 scales and no color
		  		logger.debug "+++++++ num of colors found for this row: #{num_colors_found_for_indicator} and scale length = #{ind.indicator_scales.length}"
		  		logger.debug "+++++++ i = #{i}, lower bound = #{(3*columns_per_scale + index_first_scale)}, upper bound = #{(9*columns_per_scale + index_first_scale)}"
							  if ((i==index_first_scale) || 
							      (num_colors_found_for_indicator > 0 && num_colors_found_for_indicator == ind.indicator_scales.length) || 
							      (i >= (3*columns_per_scale + index_first_scale) && i <= (9*columns_per_scale + index_first_scale)))
		  		logger.debug "++++saving record"
		  					  # Save if valid 
		  				    if ind.valid?
		  				      ind.save
		  				    else
		  				      # an error occurred, stop
		  				      msg = "Row #{n} is not valid."
		  				      raise ActiveRecord::Rollback
		  				      return msg
		  				    end
						    else
						      # scales out of range, stop
						      msg = "Row #{n} must have between 3 and 9 indicator scales."
						      raise ActiveRecord::Rollback
						      return msg
						    end
							else
				logger.debug "++++**record already exists!"
					      msg = "Row #{n} already exists in the database."
					      raise ActiveRecord::Rollback
					      return msg
							end
	  				end
  				end
  			end
  		end
		end
  logger.debug "++++procssed #{n} rows in CSV file"
    return msg 
  end

  def self.change_names_from_csv(file)
    infile = file.read
    n, msg = 0, ""
    index_en_name = 3

		Indicator.transaction do
		  CSV.parse(infile) do |row|

		    n += 1
		    # SKIP: header i.e. first row OR blank row
		    next if n == 1 or row.join.blank?
    logger.debug "++++processing row #{n}"		

        # if the event or shape type are not provided, stop
        if row[0].nil? || row[0].strip.length == 0 || row[1].nil? || row[1].strip.length == 0
  logger.debug "+++++++ event or shape type not provided"				
    		  msg = "Row #{n} - The event or shape type was not found in the spreadsheet."
  	      raise ActiveRecord::Rollback
    		  return msg
  			else
  				# get the event id
  				event = Event.find_by_name(row[0].strip)
  				# get the shape type id
  				shape_type = ShapeType.find_by_name(row[1].strip)

  				if event.nil? || shape_type.nil?
  	logger.debug "++++event or shape type was not found"				
      		  msg = "Row #{n} - The event or shape type was not found."
  		      raise ActiveRecord::Rollback
      		  return msg
  				else
            # only conintue if all values are present
            if row[2].nil? || row[3].nil? || row[4].nil? || row[5].nil? || row[6].nil? || row[7].nil? || row[8].nil?
        		  msg = "Row #{n} - Data is missing that is required to save record."
  logger.debug "+++++**missing data in row"
              raise ActiveRecord::Rollback
              return msg
            else
			logger.debug "++++found event and shape type, seeing if record already exists"
							# see if indicator already exists for the provided event and shape_type
							alreadyExists = Indicator.includes(:indicator_translations)
							  .where('indicators.event_id = ? and indicators.shape_type_id = ? and indicator_translations.locale="en" and indicator_translations.name= ?', 
							    event.id, shape_type.id, row[2].strip)
					
							if !alreadyExists.nil? && alreadyExists.length > 0
			logger.debug "++++found indicator record, populate obj"
								# update record
								ind = alreadyExists[0]
								if !row[9].nil? && row[9].strip.length > 0
									ind.number_format = row[9].strip 
								else
									ind.number_format = nil
								end
							  # translations
                ind.indicator_translations.each do |trans|
                  i = trans.locale == 'en' ? index_en_name : index_en_name+3
                  trans.name = row[i].strip
                  trans.name_abbrv = row[i+1].strip
                  trans.description = row[i+2].strip
                end

	  		logger.debug "++++saving record"
	  					  # Save if valid 
	  				    if ind.valid?
	  				      ind.save
	  				    else
	  				      # an error occurred, stop
	  				      msg = "Row #{n} is not valid."
	  				      raise ActiveRecord::Rollback
	  				      return msg
	  				    end
							else
				logger.debug "++++**record does not exist!"
					      msg = "Row #{n} does not already exist in the database."
					      raise ActiveRecord::Rollback
					      return msg
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
