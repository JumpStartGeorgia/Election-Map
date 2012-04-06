class IndicatorScale < ActiveRecord::Base
  translates :name
  require 'csv'

  belongs_to :indicator
  has_many :indicator_scale_translations, :dependent => :destroy
  accepts_nested_attributes_for :indicator_scale_translations
  attr_accessible :indicator_id, :color, :indicator_scale_translations_attributes
  attr_accessor :locale

  scope :l10n , joins(:indicator_scale_translations).where('locale = ?',I18n.locale)
  scope :by_name , order('name').l10n

  # have to turn this off so csv upload works since adding indicator and scale at same time, no indicator id exists yet
  #validates :indicator_id, :presence => true

	# get count of indicator scales for indicator
	def self.count_by_indicator(indicator_id)
		where(:indicator_id => indicator_id).count
	end

	# get an array of colors to use with the scales
	# colors are from http://colorbrewer2.org/
  def self.get_colors(indicator_id)
		if !indicator_id.nil?
			# get the number of scales for the provided indicator_id
			num_levels = count_by_indicator(indicator_id)
logger.debug "+++ num of indicator scales = #{num_levels}"
			if !num_levels.nil?
				colors = []
				case num_levels
				when 3
					colors = ["#FEE8C8", "#FDBB84", "#E34A33"]
				when 4
					colors = ["#FEF0D9", "#FDCC8A", "#FC8D59", "#D7301F"]
				when 5 
					colors = ["#FEF0D9", "#FDCC8A", "#FC8D59", "#E34A33", "#B30000"]
				when 6
					colors = ["#FEF0D9", "#FDD49E", "#FDBB84", "#FC8D59", "#E34A33", "#B30000"]
				when 7
					colors = ["#FEF0D9", "#FDD49E", "#FDBB84", "#FC8D59", "#EF6548", "#D7301F", "#990000"]
				when 8
					colors = ["#FFF7EC", "#FEE8C8", "#FDD49E", "#FDBB84", "#FC8D59", "#EF6548", "#D7301F", "#990000"]
				when 9
					colors = ["#FFF7EC", "#FEE8C8", "#FDD49E", "#FDBB84", "#FC8D59", "#EF6548", "#D7301F", "#B30000", "#7F0000"]
				end
				return colors
			end
		end
		return nil
	end
	
  def self.csv_header
    "Event, Shape Type, en: Indicator Name, en: Scale Name, ka: Scale Name, Scale Color, en: Scale Name, ka: Scale Name, Scale Color".split(",")
  end

  def self.build_from_csv(file, deleteExistingRecord)
    infile = file.read
    n, msg = 0, ""
    index_first_scale = 3
    columns_per_scale = 3

		IndicatorScale.transaction do
		  CSV.parse(infile) do |row|
        num_colors_found_for_indicator = 0 # record number of colors found

		    n += 1
		    # SKIP: header i.e. first row OR blank row
		    next if n == 1 or row.join.blank?
    logger.debug "processing row #{n}"		
  
        # if the event or shape type are not provided, stop
        if row[0].nil? || row[0].strip.length == 0 || row[1].nil? || row[1].strip.length == 0
	logger.debug "+++ event or shape type not provided"				
    		  msg = "Row #{n} - The event or shape type was not found in the spreadsheet."
		      raise ActiveRecord::Rollback
    		  return msg
				else
  				# get the event id
  				event = Event.find_by_name(row[0].strip)
  				# get the shape type id
  				shape_type = ShapeType.find_by_name(row[1].strip)

  				if event.nil? || shape_type.nil?
  	logger.debug "+++ event or shape type was not found"				
      		  msg = "Row #{n} - The event or shape type was not found in the database."
  		      raise ActiveRecord::Rollback
      		  return msg
  				else
  	logger.debug "+++ found event and shape type, seeing if indicator record exists"
  					# see if indicator exists for the provided event and shape_type
  					alreadyExists = Indicator.includes(:indicator_translations)
  						.where('indicators.event_id = ? and indicators.shape_type_id = ? and indicator_translations.locale="en" and indicator_translations.name= ?', 
  							event.id, shape_type.id, row[2].strip)
					
            # if the indicator already exists and deleteExistingRecord is true, delete the indicator scales
            if !alreadyExists.nil? && alreadyExists.length > 0 && deleteExistingRecord
	logger.debug "+++ deleting existing indicator scales"
                IndicatorScale.destroy_all (["indicator_id = ?", alreadyExists[0].id])
                alreadyExists[0].indicator_scales = []
            end

  					if !alreadyExists.nil? && alreadyExists.length > 0
  	logger.debug "+++ indicator record exists, populate scales"
  	          indicator = alreadyExists[0]

  						# populate record
  					  finishedScales = false # keep looping until find empty cell
  					  i = index_first_scale # where first scale starts
  					  until finishedScales do
  					    if row[i].nil? || row[i+1].nil?
  					      # found empty cell, stop
  					      finishedScales = true
  					    else
  					      # found scale, add it
  					      scale = indicator.indicator_scales.build
      					  scale.color = row[i+2].strip if (!row[i+2].nil? && row[i+2].strip.length > 0)
  								scale.indicator_scale_translations.build(:locale => 'en', :name => row[i].strip)
  								scale.indicator_scale_translations.build(:locale => 'ka', :name => row[i+1].strip)

                  # remember if a color was found
                  num_colors_found_for_indicator+=1 if (!row[i+2].nil? && row[i+2].strip.length > 0)

  								i+=columns_per_scale # move on to the next set of indicator scales
  					    end
  					  end
  					  # save scales if color provided for all scales or 
  					  #  there were between 3 and 9 scales and no color
    		logger.debug "+++ num of colors found for this row: #{num_colors_found_for_indicator} and scale length = #{indicator.indicator_scales.length}"
    		logger.debug "+++ i = #{i}, lower bound = #{(3*columns_per_scale + index_first_scale)}, upper bound = #{(9*columns_per_scale + index_first_scale)}"
  					  if ((num_colors_found_for_indicator > 0 && num_colors_found_for_indicator == indicator.indicator_scales.length) || 
  					      (i >= (3*columns_per_scale + index_first_scale) && i <= (9*columns_per_scale + index_first_scale)))
					    
    		logger.debug "+++ saving record"
    					  # Save if valid 
    				    if indicator.valid?
    				      indicator.save
    				    else
    				      # an error occurred, stop
    				      msg = "Row #{n} is not valid."
    				      raise ActiveRecord::Rollback
    				      return msg
    				    end
  				    else
  				      # not enough colors or scales out of range
  				      msg = "Row #{n} must have colors for every scale or, if no color provided, can only have between 3 and 9 indicator scales."
  				      raise ActiveRecord::Rollback
  				      return msg
  				    end
  					else
  		logger.debug "+++ **record does not exist!"
  			      msg = "Row #{n} indicator does not already exists in the database."
  			      raise ActiveRecord::Rollback
  			      return msg
  					end
  				end
  			end
  		end
		end
  logger.debug "+++ procssed #{n} rows in CSV file"
    return msg 
  end
	
	
end
