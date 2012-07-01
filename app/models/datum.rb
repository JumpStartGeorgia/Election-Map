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
			sql << "inner join shapes as s on i.shape_type_id = s.shape_type_id "
			sql << "inner join shape_translations as st on s.id = st.shape_id and dt.common_id = st.common_id and dt.common_name = st.common_name and dt.locale = st.locale "
			sql << "WHERE i.id = :indicator_id AND s.id = :shape_id AND dt.locale = :locale"
	
			find_by_sql([sql, :indicator_id => indicator_id, :shape_id => shape_id, :locale => I18n.locale])
		end
	end

	# get the data value for a specific shape and core indicator
	def self.get_data_for_shape_core_indicator(shape_id, event_id, core_indicator_id)
		if (!core_indicator_id.nil? && !shape_id.nil? && !event_id.nil?)
			sql = "SELECT d.id, d.value, ci.number_format, "
			sql << "stt.name_singular as 'shape_type_name', st.common_id, st.common_name,  "
			sql << "if (ci.ancestry is null, cit.name, concat(cit.name, ' (', cit_parent.name_abbrv, ')')) as 'indicator_name' "
			sql << "FROM data as d  "
			sql << "inner join datum_translations as dt on d.id = dt.datum_id  "
			sql << "inner join indicators as i on d.indicator_id = i.id  "
			sql << "inner join core_indicators as ci on i.core_indicator_id = ci.id  "
			sql << "inner join core_indicator_translations as cit on ci.id = cit.core_indicator_id and dt.locale = cit.locale  "
			sql << "left join core_indicators as ci_parent on ci.ancestry = ci_parent.id  "
			sql << "left join core_indicator_translations as cit_parent on ci_parent.id = cit_parent.core_indicator_id and dt.locale = cit_parent.locale  "
			sql << "inner join shapes as s on i.shape_type_id = s.shape_type_id  "
			sql << "inner join shape_translations as st on s.id = st.shape_id and dt.common_id = st.common_id and dt.common_name = st.common_name and dt.locale = st.locale  "
			sql << "inner join shape_types as sts on i.shape_type_id = sts.id  "
			sql << "inner join shape_type_translations as stt on sts.id = stt.shape_type_id and dt.locale = stt.locale  "
			sql << "WHERE ci.id = :core_indicator_id AND i.event_id = :event_id AND s.id = :shape_id AND dt.locale = :locale"
			find_by_sql([sql, :core_indicator_id => core_indicator_id, :event_id => event_id, 
			                  :shape_id => shape_id, :locale => I18n.locale])
		end
	end

	# get the max data value for all indicators that belong to the 
	# indicator type and event for a specific shape
	def self.get_summary_data_for_shape(shape_id, event_id, indicator_type_id, limit=nil)
		if (shape_id.nil? || event_id.nil? || indicator_type_id.nil?)
			return nil		
		else
		  # if limit is a string, convert to int
		  # will be string if value passed in via params object
	    limit = limit.to_i if !limit.nil? && limit.class == String
		  
			sql = "SELECT d.id, d.value, ci.number_format as 'number_format', stt.name_singular as 'shape_type_name', st.common_id, st.common_name, "
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
			sql << "WHERE i.event_id = :event_id and ci.indicator_type_id = :indicator_type_id and s.id =  :shape_id "
			sql << "AND dt.locale = :locale "
      sql << "order by cast(d.value as decimal(12,6)) desc "
      sql << "limit :limit" if !limit.nil?
			find_by_sql([sql, :event_id => event_id, :shape_id => shape_id, :indicator_type_id => indicator_type_id, :locale => I18n.locale, :limit => limit])
		end
	end

	# build json for a data item for the provided core indicator id
	def self.build_data_item_json(shape_id, event_id, core_indicator_id)
    json = Hash.new()
		if !shape_id.nil? && !event_id.nil? && !core_indicator_id.nil?
      json["data_item"] = Hash.new()
      json["data_item"]["shape_id"] = shape_id
      json["data_item"]["event_id"] = event_id
      json["data_item"]["core_indicator_id"] = core_indicator_id

			data = Datum.get_data_for_shape_core_indicator(shape_id, event_id, core_indicator_id)
			if !data.nil? && !data.empty?
        json["data_item"]["title"] = data[0].attributes["indicator_name"]
        json["data_item"]["shape_type_name"] = data[0].attributes["shape_type_name"]
        json["data_item"]["common_id"] = data[0].attributes["common_id"]
        json["data_item"]["common_name"] = data[0].attributes["common_name"]
        json["data_item"]["indicator_name"] = data[0].attributes["indicator_name"]
        json["data_item"]["value"] = data[0].value
        json["data_item"]["number_format"] = data[0].attributes["number_format"]
      else
        json["data_item"]["title"] = I18n.t('app.msgs.no_data')
        json["data_item"]["shape_type_name"] = nil
        json["data_item"]["common_id"] = nil
        json["data_item"]["common_name"] = nil
        json["data_item"]["indicator_name"] = I18n.t('app.msgs.no_data')
        json["data_item"]["value"] = I18n.t('app.msgs.no_data')
        json["data_item"]["number_format"] = nil
      end
		end
		return json.to_json
	end
	
	# build json for summary data for the provided indicator type
	def self.build_summary_json(shape_id, event_id, indicator_type_id, limit=nil)
    json = Hash.new()
		if !shape_id.nil? && !event_id.nil? && !indicator_type_id.nil?
      json["summary_data"] = Hash.new()
      json["summary_data"]["shape_id"] = shape_id
      json["summary_data"]["event_id"] = event_id
      json["summary_data"]["indicator_type_id"] = indicator_type_id
      json["summary_data"]["limit"] = limit

			data = Datum.get_summary_data_for_shape(shape_id, event_id, indicator_type_id, limit)
			if !data.nil? && !data.empty?
        # only need one reference to shape type common id/name
        json["summary_data"]["title"] = I18n.t("app.msgs.map_summary_legend_title", 
						:shape_type => "#{data[0].attributes["shape_type_name"]} #{data[0].attributes["common_name"]}")
        json["summary_data"]["shape_type_name"] = data[0].attributes["shape_type_name"]
        json["summary_data"]["common_id"] = data[0].attributes["common_id"]
        json["summary_data"]["common_name"] = data[0].attributes["common_name"]
        json["summary_data"]["data"] = Array.new(data.length) {Hash.new}
        
        data.each_with_index do |datum, i|
          json["summary_data"]["data"][i]["rank"] = i+1
          json["summary_data"]["data"][i]["indicator_name"] = datum.attributes["indicator_name"]
          json["summary_data"]["data"][i]["value"] = datum.value
          json["summary_data"]["data"][i]["number_format"] = datum.attributes["number_format"]
          json["summary_data"]["data"][i]["color"] = datum.attributes["color"]
        end
      end
		end
		return json.to_json
	end
	
	def self.get_related_indicator_type_data(shape_id, event_id, indicator_type_id)
    results = ''
		if !shape_id.nil? && !event_id.nil? && !indicator_type_id.nil?
  	  # get the event
  	  event = Event.find(event_id)
  	  
  	  # get the relationships for this indicator type
  	  results = build_related_indicator_json(shape_id, event_id, event.event_indicator_relationships.where(:indicator_type_id => indicator_type_id))
    end
    return results
  end
	
	def self.get_related_core_indicator_data(shape_id, event_id, core_indicator_id)
    results = ''
		if !shape_id.nil? && !event_id.nil? && !core_indicator_id.nil?
  	  # get the event
  	  event = Event.find(event_id)
  	  
  	  # get the relationships for this indicator type
  	  results = build_related_indicator_json(shape_id, event_id, event.event_indicator_relationships.where(:core_indicator_id => core_indicator_id))
    end
    return results
  end
	
  # build the json string for the provided indicator relationships
	def self.build_related_indicator_json(shape_id, event_id, relationships)
    results = ''
	  if !shape_id.nil? && !event_id.nil? && !relationships.nil? && !relationships.empty?
      results = '{ "results": ['
	    relationships.each_with_index do |rel, i|
	      if !rel.related_indicator_type_id.nil?
	        # get the summary for this indciator type
	        results << build_summary_json(shape_id, event_id, rel.related_indicator_type_id)
	        results << ", " if i < relationships.length-1
        elsif !rel.related_core_indicator_id.nil?
          # get the data item for this indciator
	        results << build_data_item_json(shape_id, event_id, rel.related_core_indicator_id)
	        results << ", " if i < relationships.length-1
        end
      end
      results << ']}'
    end
	  return results
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


	# delete all data that are assigned to the
	# provided event_id, shape_type_id, and indicator_id
	def self.delete_data(event_id, shape_type_id = nil, indicator_id = nil)
		msg = nil
		if !event_id.nil?
			# get the event				
			event = Event.find(event_id)
			if !event.nil?
				Datum.transaction do
					if !shape_type_id.nil? && !indicator_id.nil?
logger.debug "------ delete data for shape type #{shape_type_id} and indicator #{indicator_id}"
						# delete all data assigned to shape_type and indicator
						if !Datum.destroy_all(["indicator_id in (:indicator_ids)", 
								:indicator_ids => event.indicators.select("id").where(:id => indicator_id, :shape_type_id => shape_type_id).collect(&:id)])
							msg = "error occurred while deleting records"
				      raise ActiveRecord::Rollback
							return msg
						end

					elsif !shape_type_id.nil?
logger.debug "------ delete data for shape type #{shape_type_id}"
						# delete all data assigned to shape_type
						if !Datum.destroy_all(["indicator_id in (:indicator_ids)", 
								:indicator_ids => event.indicators.select("id").where(:shape_type_id => shape_type_id).collect(&:id)])
							msg = "error occurred while deleting records"
				      raise ActiveRecord::Rollback
							return msg
						end

					else
logger.debug "------ delete all data for event #{event_id}"
						# delete all data for event
						if !Datum.destroy_all(["indicator_id in (:indicator_ids)", 
								:indicator_ids => event.indicators.select("id").collect(&:id)])
							msg = "error occurred while deleting records"
				      raise ActiveRecord::Rollback
							return msg
						end
					end
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
