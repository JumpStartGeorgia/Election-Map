class Datum < ActiveRecord::Base
  translates :common_id, :common_name
	
  belongs_to :indicator
  has_many :datum_translations, :dependent => :destroy
  accepts_nested_attributes_for :datum_translations

  attr_accessible :indicator_id, :value, :datum_translations_attributes
  attr_accessor :locale

  validates :indicator_id, :value, :presence => true
	
	# define variables to be used when building json 
	# so the data translations table is not called
	def shape_id=(val)
		self[:shape_id] = val
	end
	def shape_id
		self[:shape_id]
	end
	def number_format=(val)
		self[:number_format] = val
	end
	def number_format
		self[:number_format]
	end
	def shape_type_name=(val)
		self[:shape_type_name] = val
	end
	def shape_type_name
		self[:shape_type_name]
	end
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
	def indicator_name=(val)
		self[:indicator_name] = val
	end
	def indicator_name
		self[:indicator_name]
	end
	def indicator_name_abbrv=(val)
		self[:indicator_name_abbrv] = val
	end
	def indicator_name_abbrv
		self[:indicator_name_abbrv]
	end
	def color=(val)
		self[:color] = val
	end
	def color
		self[:color]
	end

	# get the data value for a specific shape
	def self.get_data_for_shape(shape_id, indicator_id)
		if !indicator_id.nil? && !shape_id.nil?
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

	# get the data value for a shape and core indicator
	def self.get_data_for_shape_core_indicator(shapes, event_id, core_indicator_id)
		if !shapes.nil? && !shapes.empty? && !core_indicator_id.nil? && !event_id.nil?
			sql = "SELECT s.id as 'shape_id', d.id, d.value, ci.number_format, "
			sql << "stt.name_singular as 'shape_type_name', st.common_id, st.common_name,  "
			sql << "if (ci.ancestry is null, cit.name, concat(cit.name, ' (', cit_parent.name_abbrv, ')')) as 'indicator_name', "
			sql << "if (ci.ancestry is null, cit.name_abbrv, concat(cit.name_abbrv, ' (', cit_parent.name_abbrv, ')')) as 'indicator_name_abbrv' "
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
			sql << "WHERE ci.id = :core_indicator_id AND i.event_id = :event_id AND s.id in (:shape_id) AND dt.locale = :locale"
			find_by_sql([sql, :core_indicator_id => core_indicator_id, :event_id => event_id, 
			                  :shape_id => shapes.collect(&:id), :locale => I18n.locale])
		end
	end

	# get the max data value for all indicators that belong to the 
	# indicator type and event for a specific shape
	def self.get_summary_data_for_shape(shapes, event_id, indicator_type_id, limit=nil)
		if !shapes.nil? && !shapes.empty? && !event_id.nil? && !indicator_type_id.nil?
		  # if limit is a string, convert to int
		  # will be string if value passed in via params object
	    limit = limit.to_i if !limit.nil? && limit.class == String
		  		  
			sql = "SELECT s.id as 'shape_id', d.id, d.value, ci.number_format as 'number_format', stt.name_singular as 'shape_type_name', st.common_id as 'shape_common_id', st.common_name as 'shape_common_name', "
			sql << "if (ci.ancestry is null, cit.name, concat(cit.name, ' (', cit_parent.name_abbrv, ')')) as 'indicator_name', "
			sql << "if (ci.ancestry is null, cit.name_abbrv, concat(cit.name_abbrv, ' (', cit_parent.name_abbrv, ')')) as 'indicator_name_abbrv', "
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
			sql << "WHERE i.event_id = :event_id and ci.indicator_type_id = :indicator_type_id and s.id in (:shape_id) "
			sql << "AND dt.locale = :locale "
      sql << "order by cast(d.value as decimal(12,6)) desc "
      sql << "limit :limit" if !limit.nil?
			find_by_sql([sql, :event_id => event_id, :shape_id => shapes.collect(&:id), 
			                  :indicator_type_id => indicator_type_id, :locale => I18n.locale, :limit => limit])
		end
	end

	# build data item json for a core indicator id and shapes
	def self.build_data_item_json(shapes, event_id, core_indicator_id)
		start = Time.now
    json = []
		if !shapes.nil? && !shapes.empty? && !event_id.nil? && !core_indicator_id.nil?
			data = Datum.get_data_for_shape_core_indicator(shapes, event_id, core_indicator_id)
		  if !data.nil? && !data.empty?
        json = Array.new(shapes.length) {Hash.new}
        # must have record for every shape, even if shape does not have data
        # so loop through shapes and look for match in data
        shapes.each_with_index do |shape, i|
          json[i][key_data_item] = Hash.new()
          json[i][key_data_item]["shape_id"] = shape.id
          json[i][key_data_item]["event_id"] = event_id
          json[i][key_data_item]["core_indicator_id"] = core_indicator_id

          datum = data.select {|x| x.shape_id == shape.id}
    			if !datum.nil? && !datum.empty?
            json[i][key_data_item]["title"] = datum.first.indicator_name
            json[i][key_data_item]["shape_type_name"] = datum.first.shape_type_name
            json[i][key_data_item]["common_id"] = datum.first.shape_common_id
            json[i][key_data_item]["common_name"] = datum.first.shape_common_name
            json[i][key_data_item]["indicator_name"] = datum.first.indicator_name
            json[i][key_data_item]["value"] = datum.first.value
            json[i][key_data_item]["number_format"] = datum.first.number_format
          else
            json[i][key_data_item]["title"] = I18n.t('app.msgs.no_data')
            json[i][key_data_item]["shape_type_name"] = nil
            json[i][key_data_item]["common_id"] = nil
            json[i][key_data_item]["common_name"] = nil
            json[i][key_data_item]["indicator_name"] = I18n.t('app.msgs.no_data')
            json[i][key_data_item]["value"] = I18n.t('app.msgs.no_data')
            json[i][key_data_item]["number_format"] = nil
          end
    		end
  		end
		end
		logger.debug "****************** time to build data item json: #{Time.now-start} seconds for event #{event_id} and core indicator #{core_indicator_id}"
		return json
	end
	
	# build json for summary data for the provided indicator type
	def self.build_summary_json(shapes, event_id, indicator_type_id, limit=nil)
		start = Time.now
    json = []
		if !shapes.nil? && !shapes.empty? && !event_id.nil? && !indicator_type_id.nil?
			data = Datum.get_summary_data_for_shape(shapes, event_id, indicator_type_id, limit)
		  if !data.nil? && !data.empty?
        json = Array.new(shapes.length) {Hash.new}
        # must have record for every shape, even if shape does not have data
        # so loop through shapes and look for match in data
        shapes.each_with_index do |shape, i|
          json[i][key_summary_data] = Hash.new()
          json[i][key_summary_data]["shape_id"] = shape.id
          json[i][key_summary_data]["event_id"] = event_id
          json[i][key_summary_data]["indicator_type_id"] = indicator_type_id
          json[i][key_summary_data]["limit"] = limit
          
          datum = data.select {|x| x.shape_id == shape.id}
    			if !datum.nil? && !datum.empty?
            # only need one reference to shape type common id/name
            json[i][key_summary_data]["title"] = I18n.t("app.msgs.map_summary_legend_title", 
    						:shape_type => "#{data.first.shape_type_name} #{data.first.shape_common_name}")
            json[i][key_summary_data]["shape_type_name"] = datum.first.shape_type_name
            json[i][key_summary_data]["common_id"] = datum.first.shape_common_id
            json[i][key_summary_data]["common_name"] = datum.first.shape_common_name
            json[i][key_summary_data]["data"] = Array.new(datum.length) {Hash.new}

            datum.each_with_index do |d, j|
              json[i][key_summary_data]["data"][j]["rank"] = j+1
              json[i][key_summary_data]["data"][j]["indicator_name"] = d.indicator_name
              json[i][key_summary_data]["data"][j]["indicator_name_abbrv"] = d.indicator_name_abbrv
              json[i][key_summary_data]["data"][j]["value"] = d.value
              json[i][key_summary_data]["data"][j]["number_format"] = d.number_format
              json[i][key_summary_data]["data"][j]["color"] = d.color
            end
          end
        end
      end
    end
		logger.debug "****************** time to build summary data item json: #{Time.now-start} seconds for event #{event_id} and indicator type #{indicator_type_id}"
		return json
	end
	
	def self.get_related_indicator_type_data(shapes, event_id, indicator_type_id)
		start = Time.now
    data = nil
		if !shapes.nil? && !shapes.empty? && !event_id.nil? && !indicator_type_id.nil?
  	  # get the event
  	  event = Event.find(event_id)
  	  # get the relationships for this indicator type
  	  results = build_related_indicator_json(shapes, event_id, 
  	    event.event_indicator_relationships.where(:indicator_type_id => indicator_type_id))

      if !results.nil? && !results.empty?
        data = Array.new(shapes.length) {Hash.new}

        # merge the shape data from each result set onto one data set
        shapes.each_with_index do |shape, i|
          data[i][key_results] = Array.new(results[key_results].length) {Hash.new}
          results[key_results].each_with_index do |result, j|
            data[i][key_results][j] = result[i]
            
            # if this is the indicator that was passed in, get its value
            # so the map can show the correct colors
  					if result[i].has_key?(key_summary_data) && 
  							result[i][key_summary_data]["indicator_type_id"].to_s == indicator_type_id.to_s &&
  							result[i][key_summary_data].has_key?("data") && !result[i][key_summary_data]["data"].empty?

  						data[i]["shape_id"] = result[i][key_summary_data]["shape_id"]
  						data[i]["data_value"] = result[i][key_summary_data]["data"][0]["value"]
  						data[i]["value"] = result[i][key_summary_data]["data"][0]["indicator_name_abbrv"]
  						data[i]["color"] = result[i][key_summary_data]["data"][0]["color"]
  						data[i]["number_format"] = result[i][key_summary_data]["data"][0]["number_format"]
  					end
          end
        end 
      end
    end
		logger.debug "****************** time to get_related_indicator_type_data: #{Time.now-start} seconds for event #{event_id}"
    return data
  end
	
	def self.get_related_indicator_data(shapes, indicator_id)
		start = Time.new
    data = nil
		if !shapes.nil? && !shapes.empty? && !indicator_id.nil?
			# get the indicator
			indicator = Indicator.find(indicator_id)
			event = indicator.event
  	  
  	  # get the relationships for this indicator
  	  results = build_related_indicator_json(shapes, event.id, 
  	    event.event_indicator_relationships.where(:core_indicator_id => indicator.core_indicator_id))

      if !results.nil? && !results.empty?
        data = Array.new(shapes.length) {Hash.new}

        # merge the shape data from each result set onto one data set
        shapes.each_with_index do |shape, i|
          data[i][key_results] = Array.new(results[key_results].length) {Hash.new}
          results[key_results].each_with_index do |result, j|
            data[i][key_results][j] = result[i]
            
            # if this is the indicator that was passed in, get its value
            # so the map can show the correct colors
  					if result[i].has_key?(key_data_item) && 
  							result[i][key_data_item]["core_indicator_id"].to_s == indicator.core_indicator_id.to_s &&
  							!result[i][key_data_item]["value"].nil?

  						data[i]["shape_id"] = result[i][key_data_item]["shape_id"]
  						data[i]["value"] = result[i][key_data_item]["value"]
  					end
          end
        end 
      end
    end
		logger.debug "****************** time to get_related_indicator_data: #{Time.now-start} seconds for indicator #{indicator_id}"
    return data
  end
	
	def self.get_related_core_indicator_data(shapes, event_id, core_indicator_id)
		start = Time.now
    data = nil
		if !shapes.nil? && !shapes.empty? && !event_id.nil? && !core_indicator_id.nil?
  	  # get the event
  	  event = Event.find(event_id)
  	  
  	  # get the relationships for this indicator
  	  results = build_related_indicator_json(shapes, event_id, 
  	    event.event_indicator_relationships.where(:core_indicator_id => core_indicator_id))

      if !results.nil? && !results.empty?
        data = Array.new(shapes.length) {Hash.new}

        # merge the shape data from each result set onto one data set
        shapes.each_with_index do |shape, i|
          data[i][key_results] = Array.new(results[key_results].length) {Hash.new}
          results[key_results].each_with_index do |result, j|
            data[i][key_results][j] = result[i]
            
            # if this is the indicator that was passed in, get its value
            # so the map can show the correct colors
  					if result[i].has_key?(key_data_item) && 
  							result[i][key_data_item]["core_indicator_id"].to_s == core_indicator_id.to_s &&
  							!result[i][key_data_item]["value"].nil?

  						data[i]["shape_id"] = result[i][key_data_item]["shape_id"]
  						data[i]["value"] = result[i][key_data_item]["value"]
  					end
          end
        end 
      end
    end
		logger.debug "****************** time to get_related_core_indicator_data: #{Time.now-start} seconds for event #{event_id} and core indicator #{core_indicator_id}"
    return data
  end
	
  # build the json string for the provided indicator relationships
	def self.build_related_indicator_json(shapes, event_id, relationships)
    results = Hash.new()
	  if !shapes.nil? && !shapes.empty? && !event_id.nil? && !relationships.nil? && !relationships.empty?
      results[key_results] = Array.new(relationships.length) {Hash.new}
	    relationships.each_with_index do |rel, i|
	      if !rel.related_indicator_type_id.nil?
	        # get the summary for this indciator type
	        results[key_results][i] = build_summary_json(shapes, event_id, rel.related_indicator_type_id)
        elsif !rel.related_core_indicator_id.nil?
          # get the data item for this indciator
	        results[key_results][i] = build_data_item_json(shapes, event_id, rel.related_core_indicator_id)
        end
      end
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


protected

	def self.key_summary_data
		"summary_data"
	end

	def self.key_data_item
		"data_item"
	end

	def self.key_results
		"results"
	end

end
