class LiveData1 < ActiveRecord::Base
  translates :common_id, :common_name
	require 'json_cache'
	require 'json'

  belongs_to :indicator
  has_many :live_data1_translations, :dependent => :destroy
  accepts_nested_attributes_for :live_data1_translations

  attr_accessible :indicator_id, :value, :live_data1_translations
  attr_accessor :locale

  validates :indicator_id, :presence => true

	def self.test
		"this is live data 1"
	end

	# instead of returning BigDecimal, convert to string
  # this will strip away any excess zeros so 234.0000 becomes 234
  def value
    if read_attribute(:value).nil? || read_attribute(:value).to_s.downcase.strip == "null"
      return I18n.t('app.msgs.no_data')
    else
			return ActionController::Base.helpers.number_with_precision(read_attribute(:value))
    end
  end

	# format the value if it is a number
	def formatted_value
		if self.value.nil? || self.value == I18n.t('app.msgs.no_data')
			return I18n.t('app.msgs.no_data')
		else
			return ActionController::Base.helpers.number_with_delimiter(ActionController::Base.helpers.number_with_precision(self.value))
		end
	end

	def number_format
		if self.value.nil? || self.value == I18n.t('app.msgs.no_data')
			return nil
		else
			return read_attribute(:number_format)
		end
	end

	# when trying to copy the data model (e.g., d = Datum.all; x = d.first.attributes),
	# a db call is made for each data item to the translations table
	# - this will bypass the translations call and give you everything in the Datum object
	def to_hash_wout_translations
		{
			:id => self.id,
			:value => self.value,
			:formatted_value => self.formatted_value,
			:number_format => self.number_format,
			:color => self.color,
			:indicator_type_id => self.indicator_type_id,
			:indicator_type_name => self.indicator_type_name,
			:core_indicator_id => self.core_indicator_id,
			:indicator_id => self.indicator_id,
			:indicator_name => self.indicator_name,
			:indicator_name_abbrv => self.indicator_name_abbrv
=begin
,
			:shape_type_name => self.shape_type_name,
			:shape_id => self.shape_id,
			:shape_common_id => self.shape_common_id,
			:shape_common_name => self.shape_common_name
=end
		}
	end


  def self.build_from_csv(file, deleteExistingRecord)
		start = Time.now
    infile = file.read
    n, msg = 0, ""
    idx_event = 0
    idx_shape_type = 1
    idx_common_id = 2
    idx_common_name = 3
    index_first_ind = 4

		LiveData1.transaction do
		  CSV.parse(infile) do |row|
        startRow = Time.now
		    n += 1
		    # SKIP: header i.e. first row OR blank row
		    next if n == 1 or row.join.blank?
  puts "**************** processing row #{n}"

        if row[idx_event].nil? || row[idx_event].strip.length == 0 || row[idx_shape_type].nil? || row[idx_shape_type].strip.length == 0
  logger.debug "++++event or shape type was not found in spreadsheet"
    		  msg = I18n.t('models.datum.msgs.no_event_shape_spreadsheet', :row_num => n)
		      raise ActiveRecord::Rollback
          return msg
				else
          startPhase = Time.now
					# get the event id
					event = Event.find_by_name(row[idx_event].strip)
					# get the shape type id
					shape_type = ShapeType.find_by_name_singular(row[idx_shape_type].strip)
        	puts "**** time to get event and shape type: #{Time.now-startPhase} seconds"

					finishedIndicators = false
					i = index_first_ind

					until finishedIndicators do
						if row[i].nil? || row[i+1].nil?
		logger.debug "++++found empty cells, stopping processing for row"
						  # found empty cell, stop
						  finishedIndicators = true
						else
            	puts "******** loading next indicator in row"
	            # only conintue if required fields provided
	            if row[idx_common_id].nil? || row[idx_common_name].nil?
	        		  msg = I18n.t('models.datum.msgs.missing_data_spreadsheet', :row_num => n)
	  logger.debug "++++**missing data in row"
	              raise ActiveRecord::Rollback
	              return msg
	            else
                startPhase = Time.now
								# see if indicator already exists for the provided event and shape_type
								indicator = Indicator.select("indicators.id")
									.includes(:core_indicator => :core_indicator_translations)
									.where('indicators.event_id=:event_id and indicators.shape_type_id=:shape_type_id and core_indicator_translations.locale=:locale and core_indicator_translations.name=:name',
										:event_id => event.id, :shape_type_id => shape_type.id, :name => row[i].strip, :locale => "en")
              	puts "******** time to look for exisitng indicator: #{Time.now-startPhase} seconds"

		            startPhase = Time.now
								# populate record
								datum = LiveData1.new
								datum.indicator_id = indicator.first.id
								datum.value = row[i+1].strip if !row[i+1].nil? && row[i+1].downcase.strip != "null"

								# add translations
								I18n.available_locales.each do |locale|
logger.debug "++++ - adding translations for #{locale}"
									datum.live_data1_translations.build(:locale => locale,
										:common_id => row[idx_common_id].nil? ? row[idx_common_id] : row[idx_common_id].strip,
										:common_name => row[idx_common_name].nil? ? row[idx_common_name] : row[idx_common_name].strip)
								end
              	puts "******** time to build data object: #{Time.now-startPhase} seconds"


	logger.debug "++++saving record"
	              startPhase = Time.now
								if datum.valid?
									datum.save
								else
									# an error occurred, stop
							    msg = I18n.t('models.datum.msgs.not_valid', :row_num => n)
							    raise ActiveRecord::Rollback
							    return msg
								end
              	puts "******** time to save data item: #{Time.now-startPhase} seconds"

								i+=2 # move on to the next set of indicator/value pairs
							end
						end
					end
				end
			  puts "************ time to process row: #{Time.now-startRow} seconds"
			  puts "************************ total time so far : #{Time.now-start} seconds"
			end

  logger.debug "++++updating ka records with ka text in shape_names"
      startPhase = Time.now
			# ka translation is hardcoded as en in the code above
			# update all ka records with the apropriate ka translation
			# update common ids
			ActiveRecord::Base.connection.execute("update live_data1_translations as dt, shape_names as sn set dt.common_id = sn.ka where dt.locale = 'ka' and dt.common_id = sn.en")
			# update common names
			ActiveRecord::Base.connection.execute("update live_data1_translations as dt, shape_names as sn set dt.common_name = sn.ka where dt.locale = 'ka' and dt.common_name = sn.en")
      puts "************ time to update 'ka' common id and common name: #{Time.now-startPhase} seconds"

		end
    logger.debug "++++procssed #{n} rows in CSV file"
  	puts "****************** time to build_from_csv: #{Time.now-start} seconds"
    return msg
  end

end
