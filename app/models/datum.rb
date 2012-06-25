class Datum < ActiveRecord::Base
  translates :common_id, :common_name

  belongs_to :indicator
  has_many :datum_translations, :dependent => :destroy
  accepts_nested_attributes_for :datum_translations

  attr_accessible :indicator_id, :value, :datum_translations_attributes

  validates :indicator_id, :value, :presence => true


	# get the data value for a specific shape
	def self.get_data_for_shape(shape_id, indicator_id)
		if (indicator_id.nil? || shape_id.nil?)
			return nil		
		else
			sql = "SELECT d.id, d.value, ci.number_format FROM data as d "
			sql << "inner join datum_translations as dt on d.id = dt.datum_id "
			sql << "inner join indicators as i on d.indicator_id = i.id "
			sql << "inner join core_indicators as ci on i.core_indicator_id = ci.id "
			sql << "left join shapes as s on i.shape_type_id = s.shape_type_id "
			sql << "left join shape_translations as st on s.id = st.shape_id and dt.common_id = st.common_id and dt.common_name = st.common_name "
			sql << "WHERE i.id = :indicator_id AND s.id = :shape_id AND dt.locale = :locale AND st.locale = :locale"
	
			find_by_sql([sql, :indicator_id => indicator_id, :shape_id => shape_id, :locale => I18n.locale])
		end
	end

	# get the max data value for all indicators that belong to the 
	# indicator type and event for a specific shape
	def self.get_summary_data_for_shape(shape_id, event_id, indicator_type_id, limit=1)
		if (shape_id.nil? || event_id.nil? || indicator_type_id.nil?)
			return nil		
		else
		  # if limit is a string, convert to int
		  # will be string if value passed in via params object
		  if limit.class == String
		    limit = limit.to_i
		  end
		  
			sql = "SELECT d.id, d.value, ci.number_format as 'number_format', "
			sql << "itt.name as 'indicator_type_name',stt.name_singular as 'shape_type_name', st.common_id, st.common_name,  "
			sql << "if (ci.ancestry is null, cit.name, concat(cit.name, ' (', cit_parent.name_abbrv, ')')) as 'indicator_name', "
			sql << "if(ci.ancestry is null OR (ci.ancestry is not null AND (ci.color is not null AND length(ci.color)>0)),ci.color,ci_parent.color) as 'color' "
			sql << "FROM data as d "
			sql << "inner join datum_translations as dt on d.id = dt.datum_id "
			sql << "inner join indicators as i on d.indicator_id = i.id "
			sql << "inner join core_indicators as ci on i.core_indicator_id = ci.id "
			sql << "inner join core_indicator_translations as cit on ci.id = cit.core_indicator_id and dt.locale = cit.locale "
			sql << "left join core_indicators as ci_parent on ci.ancestry = ci_parent.id "
			sql << "left join core_indicator_translations as cit_parent on ci_parent.id = cit_parent.core_indicator_id and dt.locale = cit_parent.locale "
			sql << "inner join shapes as s on i.shape_type_id = s.shape_type_id "
			sql << "inner join shape_translations as st on s.id = st.shape_id and dt.common_id = st.common_id and dt.common_name = st.common_name and dt.locale = st.locale "
      sql << "inner join shape_types as sts on i.shape_type_id = sts.id "
      sql << "inner join shape_type_translations as stt on sts.id = stt.shape_type_id and dt.locale = stt.locale "
			sql << "inner join indicator_types as it on ci.indicator_type_id = it.id "
			sql << "inner join indicator_type_translations as itt on it.id = itt.indicator_type_id and dt.locale = itt.locale "
			sql << "WHERE i.event_id = :event_id and ci.indicator_type_id = :indicator_type_id and s.id =  :shape_id "
			sql << "AND dt.locale = :locale "
      sql << "order by cast(d.value as decimal(12,6)) desc "
      sql << "limit :limit"
			find_by_sql([sql, :event_id => event_id, :shape_id => shape_id, :indicator_type_id => indicator_type_id, :locale => I18n.locale, :limit => limit])
		end
	end


	# create the properly formatted json string
	def self.build_summary_json(shape_id, event_id, indicator_type_id, limit=1)
		json = ''
		if !shape_id.nil? && !event_id.nil? && !indicator_type_id.nil?
			json = '{ "summary_data": {'
			json << '"shape_id":"'
			json << shape_id.to_s
			json << '", "event_id":"'
			json << event_id.to_s
			json << '", "indicator_type_id":"'
			json << indicator_type_id.to_s
			json << '", "limit":"'
			json << limit.to_s

			data = Datum.get_summary_data_for_shape(shape_id, event_id, indicator_type_id, limit)
			if !data.nil? && !data.empty?
        # only need one reference to shape type common id/name
				json << '", "title_location":"'
				json << "#{data[0].attributes["shape_type_name"]}: #{data[0].attributes["common_name"]}"
				json << '", "title_summary":"'
				json << I18n.t("app.msgs.indicator_summary_link", :name => data[0].attributes["indicator_type_name"])
				json << '", "shape_type_name":"'
				json << data[0].attributes["shape_type_name"]
				json << '", "common_id":"'
				json << data[0].attributes["common_id"]
				json << '", "common_name":"'
				json << data[0].attributes["common_name"]
  			json << '", "data": ['
        data.each_with_index do |datum, i|
  				json << '{"rank":"'
  				json << (i+1).to_s
					json << '", "indicator_name":"'
					json << datum.attributes["indicator_name"]
					json << '", "value":"'
					json << datum.value
					json << '", "number_format":"'
					json << datum.attributes["number_format"] if !datum.attributes["number_format"].nil? 
					json << '", "color":"'
					json << datum.attributes["color"] if !datum.attributes["color"].nil? 
          if i < data.length-1 # if this is last item, do not include ','
  				  json << '"}, '
  				else
  				  json << '"} '
				  end
        end
  			json << ']' # close data array
      end

			json << '}}'
		end
		return json
	end

  def self.csv_header
    "Event, Shape Type, Common ID, Common Name, Indicator, Value, Indicator, Value".split(",")
  end

  def self.download_header
    "Event, Map Level, [Level] ID, [Level] Name".split(",")
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
					shape_type = ShapeType.find_by_name_singular(row[1].strip)

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
									indicator = Indicator.includes(:core_indicator => :core_indicator_translations)
										.where('indicators.event_id=:event_id and indicators.shape_type_id=:shape_type_id and core_indicator_translations.locale=:locale and core_indicator_translations.name=:name', 
											:event_id => event.id, :shape_type_id => shape_type.id, :name => row[i].strip, :locale => "en")
					
									if indicator.nil? || indicator.empty?
					logger.debug "++++indicator was not found"
										msg = I18n.t('models.datum.msgs.indicator_not_found', :row_num => n)
										raise ActiveRecord::Rollback
										return msg
									else
					logger.debug "++++indicator found, checking if data exists"
										# check if data already exists
										alreadyExists = Datum.joins(:datum_translations)
											.where(:data => {:indicator_id => indicator.first.id}, 
												:datum_translations => {
													:locale => 'en',
													:common_id => row[2].nil? ? row[2] : row[2].strip, 
													:common_name => row[3].nil? ? row[3] : row[3].strip})
					
				            # if the datum already exists and deleteExistingRecord is true, delete the datum
				            if !alreadyExists.nil? && alreadyExists.length > 0 && deleteExistingRecord
					logger.debug "+++++++ deleting existing #{alreadyExists.length} datum records "
					              alreadyExists.each do |exists|
				                  Datum.destroy (exists.id)
                        end
				                alreadyExists = nil
				            end

										if alreadyExists.nil? || alreadyExists.empty?
					logger.debug "++++data does not exist, save it"
											# populate record
											datum = Datum.new
											datum.indicator_id = indicator.first.id
											datum.value = row[i+1].nil? ? row[i+1] : row[i+1].strip

											# add translations
											I18n.available_locales.each do |locale|
			logger.debug "++++ - adding translations for #{locale}"
												datum.datum_translations.build(:locale => locale, 
													:common_id => row[2].nil? ? row[2] : row[2].strip, 
													:common_name => row[3].nil? ? row[3] : row[3].strip)
											end


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

  logger.debug "++++updating ka records with ka text in shape_names"
			# ka translation is hardcoded as en in the code above
			# update all ka records with the apropriate ka translation
			# update common ids
			ActiveRecord::Base.connection.execute("update datum_translations as dt, shape_names as sn set dt.common_id = sn.ka where dt.locale = 'ka' and dt.common_id = sn.en")
			# update common names
			ActiveRecord::Base.connection.execute("update datum_translations as dt, shape_names as sn set dt.common_name = sn.ka where dt.locale = 'ka' and dt.common_name = sn.en")

		end
  logger.debug "++++procssed #{n} rows in CSV file"
    return msg 
  end


	def self.create_csv(event_id, shape_type_id, shape_id, indicator_id=nil)
		obj = OpenStruct.new
		obj.csv_data = nil
		obj.msg = nil

		# parameters must be provided
    if event_id.nil? || shape_type_id.nil? || shape_id.nil?
logger.debug "not all params provided"
			return nil
    else
			# get the shapes we need data for
			shapes = Shape.get_shapes_for_download(shape_id, shape_type_id)

			if shapes.nil? || shapes.empty?
logger.debug "no shapes were found"
				return nil
		  else
				# get the data for the provided parameters
				if indicator_id.nil?
					# get data for all indicators
		      indicators = Indicator.includes({:event => :event_translations}, {:shape_type => :shape_type_translations}, {:core_indicator => :core_indicator_translations}, {:data => :datum_translations})
		        .where("indicators.event_id = :event_id and indicators.shape_type_id = :shape_type_id and event_translations.locale = :locale and shape_type_translations.locale = :locale and core_indicator_translations.locale = :locale and datum_translations.locale = :locale and datum_translations.common_id in (:common_ids) and datum_translations.common_name in (:common_names)", 
		          :event_id => event_id, :shape_type_id => shape_type_id, :locale => I18n.locale, 
							:common_ids => shapes.collect(&:common_id), :common_names => shapes.collect(&:common_name))
		        .order("indicators.id ASC, data.id asc")
				else
					# get data for provided indicator
		      indicators = Indicator.includes({:event => :event_translations}, {:shape_type => :shape_type_translations}, {:core_indicator => :core_indicator_translations}, {:data => :datum_translations})
		        .where("indicators.id = :indicator_id and event_translations.locale = :locale and shape_type_translations.locale = :locale and core_indicator_translations.locale = :locale and datum_translations.locale = :locale and datum_translations.common_id in (:common_ids) and datum_translations.common_name in (:common_names)", 
		          :indicator_id => indicator_id, :locale => I18n.locale, 
							:common_ids => shapes.collect(&:common_id), :common_names => shapes.collect(&:common_name))
		        .order("indicators.id ASC, data.id asc")
				end

		    if indicators.nil? || indicators.empty?
	logger.debug "no indicators or data found"
		      return nil
		    else
		      # create the csv data
		      rows =[]
					row_starter = []
		      indicators.each_with_index do |ind, index|
						if index == 0
							#event
				      if ind.event.event_translations.nil? || ind.event.event_translations.empty?
		logger.debug "no event translation found"
				        return nil
				      else
				        row_starter << ind.event.event_translations[0].name
				      end
							# shape type
				      if ind.shape_type.shape_type_translations.nil? || ind.shape_type.shape_type_translations.empty?
		logger.debug "no shape type translation found"
				        return nil
				      else
				        row_starter << ind.shape_type.shape_type_translations[0].name_singular
				      end
						end 

						if ind.data.nil? || ind.data.empty?
	logger.debug "no data"
		          return nil
						else
							ind.data.each_with_index do |d, dindex|
								if index > 0
									# this is not the first indicator, so get existing row and add to it
					        row = rows[dindex]
								else
									# this is first indicator, create rows
									row = []
									# add first couple columns of row (event and shape type)
									row << row_starter
									# common id
									row << d.common_id
									# common name
									row << d.common_name
								end
								# data
								row << d.value

								# only add the row if it is new
								if index == 0
								  # add the row to the rows array
								  rows << row.flatten
								end
							end
						end
		      end

					# remove any line returns for excel does not like them
					rows.each do |r|
						r.each do |c|
							c.gsub(/\r?\n/, ' ').strip!
						end
					end
		      
					# use tab as separator for excel does not like ','
#					obj.csv_data = CSV.generate(:col_sep => "\t", :force_quotes => true) do |csv|
					obj.csv_data = CSV.generate(:col_sep => ",", :force_quotes => true) do |csv|
				    # generate the header
				    header = []
						# replace the [Level] placeholder in download_header with the name of the map level
						# that is located in the row_starter array
				    header << download_header.join("||").gsub("[Level]", row_starter[1]).split("||")
				    indicators.each do |i|
				      header << i.description
				    end
				    csv << header.flatten
				    
				    # add the rows
				    rows.each do |r|
				      csv << r
				    end

					end

					# convert to utf-8
					# the bom is used to indicate utf-16le which excel requires
#				  bom = "\xEF\xBB\xBF".force_encoding("UTF-8") #Byte Order Mark UTF-8
#					obj.csv_data = (bom + obj.csv_data).force_encoding("UTF-8")
					
					
		      return obj
				end
			end
		end
	end
=begin
# code for testing csv download that works in excel
	def as_csv(options = {})
		csv = {
		  common_id: self.common_id,
		  common_name: self.common_name,
		  value: self.value
		}
	end

	def self.test_csv(event_id, shape_type_id, shape_id, indicator_id=nil)

			shapes = Shape.get_shapes_for_download(shape_id, shape_type_id)
      indicators = Indicator.includes({:event => :event_translations}, {:shape_type => :shape_type_translations}, :indicator_translations, {:data => :datum_translations})
        .where("indicators.event_id = :event_id and indicators.shape_type_id = :shape_type_id and event_translations.locale = :locale and shape_type_translations.locale = :locale and indicator_translations.locale = :locale and datum_translations.locale = :locale and datum_translations.common_id in (:common_ids) and datum_translations.common_name in (:common_names)", 
          :event_id => event_id, :shape_type_id => shape_type_id, :locale => I18n.locale, 
					:common_ids => shapes.collect(&:common_id), :common_names => shapes.collect(&:common_name))
        .order("indicators.id ASC, data.id asc")

			if !indicators.empty?
				return indicators.first.data
			end		

	end
=end

end
