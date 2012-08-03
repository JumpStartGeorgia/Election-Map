class Datum < ActiveRecord::Base
  translates :common_id, :common_name
	include ActionView::Helpers::NumberHelper

  belongs_to :indicator
  has_many :datum_translations, :dependent => :destroy
  accepts_nested_attributes_for :datum_translations

  attr_accessible :indicator_id, :value, :datum_translations_attributes
  attr_accessor :locale

  validates :indicator_id, :presence => true

	# instead of returning BigDecimal, convert to string
  # this will strip away any excess zeros so 234.0000 becomes 234
  def value
    if read_attribute(:value).nil? || read_attribute(:value).to_s.downcase.strip == "null"
      return I18n.t('app.msgs.no_data')
    else
			return number_with_precision(read_attribute(:value))
    end
  end

	# format the value if it is a number
	def formatted_value
		if self.value.nil? || self.value == I18n.t('app.msgs.no_data')
			return I18n.t('app.msgs.no_data')
		else
			return number_with_delimiter(number_with_precision(self.value))
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

	# get the data value for a specific shape
	def self.get_data_for_shape(shape_id, indicator_id)
		if !indicator_id.nil? && !shape_id.nil?
			sql = "SELECT d.id, d.value, ci.number_format FROM data as d "
			sql << "inner join datum_translations as dt on d.id = dt.datum_id "
			sql << "inner join indicators as i on d.indicator_id = i.id "
			sql << "inner join core_indicators as ci on i.core_indicator_id = ci.id "
			sql << "inner join shapes as s on i.shape_type_id = s.shape_type_id "
			sql << "inner join shape_translations as st on s.id = st.shape_id and dt.common_id = st.common_id and dt.common_name = st.common_name and dt.locale = st.locale "
			sql << "WHERE i.id = :indicator_id AND s.id = :shape_id AND dt.locale = :locale "

			find_by_sql([sql, :indicator_id => indicator_id, :shape_id => shape_id, :locale => I18n.locale])
		end
	end

	# get the data value for a shape and core indicator
	def self.get_data_for_shape_core_indicator(shape_id, event_id, shape_type_id, core_indicator_id)
    start = Time.now
    x = nil
		if !shape_id.nil? && !core_indicator_id.nil? && !event_id.nil? && !shape_type_id.nil?
			sql = "SELECT s.id as 'shape_id', i.id as 'indicator_id', ci.indicator_type_id, "
			sql << "d.id, d.value, ci.number_format as 'number_format', "
#			sql << "stt.name_singular as 'shape_type_name', st.common_id as 'shape_common_id', st.common_name as 'shape_common_name', "
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
#			sql << "inner join shape_types as sts on i.shape_type_id = sts.id  "
#			sql << "inner join shape_type_translations as stt on sts.id = stt.shape_type_id and dt.locale = stt.locale  "
			sql << "WHERE ci.id = :core_indicator_id AND i.event_id = :event_id AND i.shape_type_id = :shape_type_id "
			sql << "and s.id=:shape_id "
			sql << "AND dt.locale = :locale "
      sql << "order by s.id asc "
			x = find_by_sql([sql, :core_indicator_id => core_indicator_id, :event_id => event_id,
			                  :shape_id => shape_id,
			                  :shape_type_id => shape_type_id, :locale => I18n.locale])
		end
#		puts "********************* time to query data for core indicator: #{Time.now-start} seconds for event #{event_id} and core indicator #{core_indicator_id} - # of results = #{x.length}"
    return x
	end

	# get the max data value for all indicators that belong to the
	# indicator type and event for a specific shape

	def self.get_summary_data_for_shape(shape_id, event_id, shape_type_id, indicator_type_id, limit=nil)

    start = Time.now
    x = nil
		if !shape_id.nil? && !event_id.nil? && !indicator_type_id.nil? && !shape_type_id.nil?
		  # if limit is a string, convert to int
		  # will be string if value passed in via params object
	    limit = limit.to_i if !limit.nil? && limit.class == String


			sql = "SELECT s.id as 'shape_id', i.id as 'indicator_id', ci.indicator_type_id, itt.name as 'indicator_type_name', "
			sql << "d.id, d.value, ci.number_format as 'number_format', "
#			sql << "stt.name_singular as 'shape_type_name', st.common_id as 'shape_common_id', st.common_name as 'shape_common_name', "

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
			sql << "inner join indicator_type_translations as itt on ci.indicator_type_id = itt.indicator_type_id and dt.locale = itt.locale "
			sql << "inner join shapes as s on i.shape_type_id = s.shape_type_id "
			sql << "inner join shape_translations as st on s.id = st.shape_id and dt.common_id = st.common_id and dt.common_name = st.common_name and dt.locale = st.locale "

#      sql << "inner join shape_types as sts on i.shape_type_id = sts.id "
#      sql << "inner join shape_type_translations as stt on sts.id = stt.shape_type_id and dt.locale = stt.locale "
			sql << "WHERE i.event_id = :event_id and i.shape_type_id = :shape_type_id and ci.indicator_type_id = :indicator_type_id "
			sql << "and s.id=:shape_id "
			sql << "AND dt.locale = :locale "
      sql << "order by s.id asc, d.value desc "
      sql << "limit :limit" if !limit.nil?
			x = find_by_sql([sql, :event_id => event_id, :shape_type_id => shape_type_id,
			                  :shape_id => shape_id,
			                  :indicator_type_id => indicator_type_id, :locale => I18n.locale, :limit => limit])

		end
#		puts "********************* time to query summary data for indicator type: #{Time.now-start} seconds for event #{event_id} and indicator type #{indicator_type_id} - # of results = #{x.length}"
    return x
	end


	def self.get_related_indicator_type_data(shape_id, shape_type_id, event_id, indicator_type_id)
		start = Time.now
    results = nil
		if !shape_id.nil? && !shape_type_id.nil? && !event_id.nil? && !indicator_type_id.nil?

  	  # get the event
  	  event = Event.find(event_id)
  	  # get the relationships for this indicator type
  	  results = build_related_indicator_json(shape_id, shape_type_id, event_id,
  	    event.event_indicator_relationships.where(:indicator_type_id => indicator_type_id))
    end
#		puts "******* time to get_related_indicator_type_data: #{Time.now-start} seconds for event #{event_id}"
    return results
  end

	def self.get_related_indicator_data(shape_id, indicator_id)
		start = Time.new
    results = nil
		if !shape_id.nil? && !indicator_id.nil?
			# get the indicator
			indicator = Indicator.find(indicator_id)
			event = indicator.event

  	  # get the relationships for this indicator
  	  results = build_related_indicator_json(shape_id, indicator.shape_type_id, event.id,
  	    event.event_indicator_relationships.where(:core_indicator_id => indicator.core_indicator_id))
    end
#		puts "******* time to get_related_indicator_data: #{Time.now-start} seconds for indicator #{indicator_id}"
    return results
  end

	def self.get_related_core_indicator_data(shape_id, shape_type_id, event_id, core_indicator_id)
		start = Time.now
    results = nil
		if !shape_id.nil? && !shape_type_id.nil? && !event_id.nil? && !core_indicator_id.nil?
  	  # get the event
  	  event = Event.find(event_id)

  	  # get the relationships for this indicator
  	  results = build_related_indicator_json(shape_id, shape_type_id, event_id,
  	    event.event_indicator_relationships.where(:core_indicator_id => core_indicator_id))
    end
#		puts "****************** time to get_related_core_indicator_data: #{Time.now-start} seconds for event #{event_id} and core indicator #{core_indicator_id}"
    return results
  end

  # build the json string for the provided indicator relationships
	def self.build_related_indicator_json(shape_id, shape_type_id, event_id, relationships)
    results = []
	  if !shape_id.nil? && !event_id.nil? && !shape_type_id.nil? && !relationships.nil? && !relationships.empty?
#      results = Array.new(relationships.length) {Hash.new}
	    relationships.each do |rel|
	      if !rel.related_indicator_type_id.nil?
	        # get the summary for this indciator type
					data = get_summary_data_for_shape(shape_id, event_id, shape_type_id, rel.related_indicator_type_id)
					if data && !data.empty?
						data_hash = Hash.new
						data_hash["summary_data"] = data
	        	results << data_hash
					end
        elsif !rel.related_core_indicator_id.nil?
          # get the data item for this indciator
					data = get_data_for_shape_core_indicator(shape_id, event_id, shape_type_id, rel.related_core_indicator_id)
					if data && !data.empty?
						data_hash = Hash.new
						data_hash["data_item"] = data
	        	results << data_hash
					end
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
		start = Time.now
    infile = file.read
    n, msg = 0, ""
    idx_event = 0
    idx_shape_type = 1
    idx_common_id = 2
    idx_common_name = 3
    index_first_ind = 4

		Datum.transaction do
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

					if event.nil? || shape_type.nil?
			logger.debug "++++event or shape type was not found"
		  		  msg = I18n.t('models.datum.msgs.no_event_shape_db', :row_num => n)
				    raise ActiveRecord::Rollback
		  		  return msg
					else
			logger.debug "++++event and shape found, procesing indicators"
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

									if indicator.nil? || indicator.empty?
					logger.debug "++++indicator was not found"
										msg = I18n.t('models.datum.msgs.indicator_not_found', :row_num => n)
										raise ActiveRecord::Rollback
										return msg
									else
					logger.debug "++++indicator found, checking if data exists"
                    startPhase = Time.now
										# check if data already exists
										alreadyExists = Datum.select("data.id").joins(:datum_translations)
											.where(:data => {:indicator_id => indicator.first.id},
												:datum_translations => {
													:locale => 'en',
													:common_id => row[idx_common_id].nil? ? row[idx_common_id] : row[idx_common_id].strip,
													:common_name => row[idx_common_name].nil? ? row[idx_common_name] : row[idx_common_name].strip})

                  	puts "******** time to look for exisitng data item: #{Time.now-startPhase} seconds"

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
					            startPhase = Time.now
											# populate record
											datum = Datum.new
											datum.indicator_id = indicator.first.id
											datum.value = row[i+1].strip if !row[i+1].nil? && row[i+1].downcase.strip != "null"

											# add translations
											I18n.available_locales.each do |locale|
			logger.debug "++++ - adding translations for #{locale}"
												datum.datum_translations.build(:locale => locale,
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
			  puts "************ time to process row: #{Time.now-startRow} seconds"
			  puts "************************ total time so far : #{Time.now-start} seconds"
			end

  logger.debug "++++updating ka records with ka text in shape_names"
      startPhase = Time.now
			# ka translation is hardcoded as en in the code above
			# update all ka records with the apropriate ka translation
			# update common ids
			ActiveRecord::Base.connection.execute("update datum_translations as dt, shape_names as sn set dt.common_id = sn.ka where dt.locale = 'ka' and dt.common_id = sn.en")
			# update common names
			ActiveRecord::Base.connection.execute("update datum_translations as dt, shape_names as sn set dt.common_name = sn.ka where dt.locale = 'ka' and dt.common_name = sn.en")
      puts "************ time to update 'ka' common id and common name: #{Time.now-startPhase} seconds"

		end
    logger.debug "++++procssed #{n} rows in CSV file"
  	puts "****************** time to build_from_csv: #{Time.now-start} seconds"
    return msg
  end


def self.get_table_data(event_id, shape_type_id, shape_id, indicator_id=nil, include_indicator_ids = false, pretty_data = false)
  if event_id.nil? || shape_type_id.nil? || shape_id.nil?
  logger.debug "=========== not all params provided"
  return nil
    else
      # get the shapes we need data for
      shapes = Shape.get_shapes_by_type(shape_id, shape_type_id)

      if shapes.nil? || shapes.empty?
logger.debug "=========== no shapes were found"
        return nil
      else
        # get the data for the provided parameters
        if indicator_id.nil?
logger.debug "=========== getting data for all indicators"
          # get data for all indicators
          indicators = Indicator.includes({:event => :event_translations}, {:shape_type => :shape_type_translations}, {:core_indicator => [:core_indicator_translations, :indicator_type]}, {:data => :datum_translations})
            .where("indicators.event_id = :event_id and indicators.shape_type_id = :shape_type_id and event_translations.locale = :locale and shape_type_translations.locale = :locale and core_indicator_translations.locale = :locale and datum_translations.locale = :locale and datum_translations.common_id in (:common_ids) and datum_translations.common_name in (:common_names)",
              :event_id => event_id, :shape_type_id => shape_type_id, :locale => I18n.locale,
              :common_ids => shapes.collect(&:common_id), :common_names => shapes.collect(&:common_name))
            .order("indicator_types.sort_order asc, core_indicator_translations.name_abbrv ASC, datum_translations.common_name asc")
        else
logger.debug "=========== getting data for 1 indicator"
          # get data for provided indicator
          indicators = Indicator.includes({:event => :event_translations}, {:shape_type => :shape_type_translations}, {:core_indicator => [:core_indicator_translations, :indicator_type]}, {:data => :datum_translations})
            .where("indicators.id = :indicator_id and event_translations.locale = :locale and shape_type_translations.locale = :locale and core_indicator_translations.locale = :locale and datum_translations.locale = :locale and datum_translations.common_id in (:common_ids) and datum_translations.common_name in (:common_names)",
              :indicator_id => indicator_id, :locale => I18n.locale,
              :common_ids => shapes.collect(&:common_id), :common_names => shapes.collect(&:common_name))
            .order("indicator_types.sort_order asc, core_indicator_translations.name_abbrv ASC, datum_translations.common_name asc")
        end
      end

        if indicators.nil? || indicators.empty?
  logger.debug "=========== no indicators or data found"
          return nil
        else
          # create the csv data
          rows = []
          row_starter = []
          maxvalue = {}
          winner = {}
          indicators.each_with_index do |ind, index|
            if index == 0
              #event
              if ind.event.event_translations.nil? || ind.event.event_translations.empty?
    logger.debug "=========== no event translation found"
                return nil
              else
                row_starter << ind.event.event_translations[0].name
              end
              # shape type
              if ind.shape_type.shape_type_translations.nil? || ind.shape_type.shape_type_translations.empty?
    logger.debug "=========== no shape type translation found"
                return nil
              else
                row_starter << ind.shape_type.shape_type_translations[0].name_singular
              end
            end

            if ind.data.nil? || ind.data.empty?
  logger.debug "=========== no data"
              return nil
            else
              ind.data.each_with_index do |d, dindex|
                if ind.core_indicator.indicator_type.has_summary &&
                   (maxvalue[d.common_name].nil? || d.value.to_f > maxvalue[d.common_name])
                  maxvalue[d.common_name] = d.value.to_f
                  winner[d.common_name] = ind.description
                end

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
                if pretty_data
                  row << d.formatted_value
                else
                  row << d.value
                end

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
            c.to_s.gsub(/\r?\n/, ' ').strip!
          end
        end

        data = []
        # generate the header
        header = []
        # replace the [Level] placeholder in download_header with the name of the map level
        # that is located in the row_starter array
        header << download_header.join("||").gsub("[Level]", row_starter[1]).split("||")
        ind_ids = header.clone
        indicators.each do |i|
          header << i.description
          ind_ids << i.id
        end
        data << ind_ids.flatten
        data << header.flatten

        # add the rows
        rows.each do |r|
          data << r
        end

        return {:data => data, :winner => winner}
      end
    end
  end

	def self.create_csv(event_id, shape_type_id, shape_id, indicator_id=nil)
		obj = OpenStruct.new
		obj.csv_data = nil
		obj.msg = nil

    if event_id.nil? || shape_type_id.nil? || shape_id.nil?
logger.debug "not all params provided"
			return nil
    else
			data = get_table_data(event_id, shape_type_id, shape_id, indicator_id)

	    if data.nil? || data.empty?
logger.debug "no indicators or data found"
	      return nil
	    else
				# use tab as separator for excel does not like ','
#					obj.csv_data = CSV.generate(:col_sep => "\t", :force_quotes => true) do |csv|
				obj.csv_data = CSV.generate(:col_sep => ",", :force_quotes => true) do |csv|
			    # add the rows
			    data.each do |r|
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

			shapes = Shape.get_shapes_by_type(shape_id, shape_type_id)
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
#	def number_format
#		self[:number_format]
#	end
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
	def indicator_type_id=(val)
		self[:indicator_type_id] = val
	end
	def indicator_type_id
		self[:indicator_type_id]
	end
	def indicator_type_name=(val)
		self[:indicator_type_name] = val
	end
	def indicator_type_name
		self[:indicator_type_name]
	end

end
