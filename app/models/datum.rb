class Datum < ActiveRecord::Base
  translates :common_id, :common_name
	include ActionView::Helpers::NumberHelper
	require 'json_cache'
	require 'json'

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

=begin
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
=end

	# get the data value for a shape and core indicator
	def self.get_data_for_shape_core_indicator(shape_id, event_id, shape_type_id, core_indicator_id)
    start = Time.now
    x = nil
		if !shape_id.nil? && !core_indicator_id.nil? && !event_id.nil? && !shape_type_id.nil?
			sql = "SELECT s.id as 'shape_id', i.id as 'indicator_id', i.core_indicator_id, ci.indicator_type_id, "
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
			sql << "WHERE i.event_id = :event_id AND i.shape_type_id = :shape_type_id AND i.core_indicator_id = :core_indicator_id "
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


			sql = "SELECT s.id as 'shape_id', i.id as 'indicator_id', i.core_indicator_id, ci.indicator_type_id, itt.name as 'indicator_type_name', "
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
      has_duplicates = false
	    relationships.each do |rel|
	      if !rel.related_indicator_type_id.nil?
	        # get the summary for this indciator type
					data = get_indicator_type_data(shape_id, shape_type_id, event_id, rel.related_indicator_type_id)
					if data && !data["summary_data"].empty?
	        	results << data
					end
        elsif !rel.related_core_indicator_id.nil?
          # see if indicator is part of indicator type that has summary
          # if so, get the summary info so can assign the overall placement and overall winner
          core = CoreIndicator.get_indicator_type_with_summary(rel.related_core_indicator_id)
          if core
            # get summary data
  					data = get_indicator_type_data(shape_id, shape_type_id, event_id, core.indicator_type_id)
  					if data && !data["summary_data"].empty?
              # add the data item for the provided indicator
              index = data["summary_data"].index{|x| x[:core_indicator_id] == rel.related_core_indicator_id}
              if index
    						data_hash = Hash.new
    						data_hash["data_item"] = data["summary_data"][index]
    	        	results << data_hash

                # add the placement of this indicator
								# if value != no data
								# if there are duplicate values (e.g., a tie) fix the rank accordingly
								if data["summary_data"][index][:value] != I18n.t('app.msgs.no_data')
								  #&& data["summary_data"][index][:value] != "0"

                  # returns {:rank, :total, :has_duplicates}
                  h = compute_placement(data["summary_data"], data["summary_data"][index][:value])
                  has_duplicates = h[:has_duplicates]
                  if !h.nil? && !h.empty?
  		              rank = Datum.new
  		              rank.value = h[:rank].to_s
  		              rank["number_format"] = " / #{h[:total]}"
  		              rank["number_format"] += " *" if h[:has_duplicates]
  		              rank["indicator_type_name"] = data["summary_data"][index][:indicator_type_name]
  		              rank["indicator_name"] = I18n.t('app.common.overall_placement')
  		              rank["indicator_name_abbrv"] = I18n.t('app.common.overall_placement')
  		  						data_hash = Hash.new
  		  						data_hash["data_item"] = rank.to_hash_wout_translations
  		  	        	results << data_hash
                  end
								end

	              # add total # of indicators in the summary
	              rank = Datum.new
	              rank.value = data["summary_data"].length
	              rank["indicator_type_name"] = data["summary_data"][index]["indicator_type_name"]
	              rank["indicator_name"] = I18n.t('app.common.total_participants')
	              rank["indicator_name_abbrv"] = I18n.t('app.common.total_participants')
	  						data_hash = Hash.new
	  						data_hash["data_item"] = rank.to_hash_wout_translations
	  	        	results << data_hash
              end

              # add the winner if this record is not it and if value != no data or 0
							if index > 0 &&
									data["summary_data"][0][:value] != "0" &&
									data["summary_data"][0][:value] != I18n.t('app.msgs.no_data')

                data["summary_data"][0][:indicator_name].insert(0, "#{I18n.t('app.common.winner')}: ")
                data["summary_data"][0][:indicator_name_abbrv].insert(0, "#{I18n.t('app.common.winner')}: ")
    						data_hash = Hash.new
    						data_hash["data_item"] = data["summary_data"][0]
    	        	results << data_hash
              end
  					end
          else
            # indicator type does not have summary
            # get the data item for this indciator
  					data = get_data_for_shape_core_indicator(shape_id, event_id, shape_type_id, rel.related_core_indicator_id)
  					if data && !data.empty?
  						data_hash = Hash.new
  						data_hash["data_item"] = data.first.to_hash_wout_translations
  	        	results << data_hash
  					end
          end
        end
      end

      # add duplicate footnote if needed
      if has_duplicates
        footnote = Datum.new
        footnote["indicator_name"] = "* #{I18n.t('app.common.footnote_duplicates')}"
        footnote["indicator_name_abbrv"] = "* #{I18n.t('app.common.footnote_duplicates')}"
				data_hash = Hash.new
				data_hash["footnote"] = footnote.to_hash_wout_translations
      	results << data_hash
      end
    end
	  return results
  end

  # get the summary data for an indicator type in an event for a shape
	def self.get_indicator_type_data(shape_id, shape_type_id, event_id, indicator_type_id)
		start = Time.now
		results = Hash.new
		results["summary_data"] = []
		if !shape_id.nil? && !shape_type_id.nil? && !event_id.nil? && !indicator_type_id.nil?
			json = []
  		key = "summary_data/#{I18n.locale}/indicator_type_#{indicator_type_id}/shape_type_#{shape_type_id}/shape_#{shape_id}"
  		json = JsonCache.fetch(event_id, key) {
  			data = get_summary_data_for_shape(shape_id, event_id, shape_type_id, indicator_type_id)
				x = []
  			if data && !data.empty?
  				x = data.collect{|x| x.to_hash_wout_translations}
  			end
				x.to_json
  		}
			results["summary_data"] = JSON.parse(json,:symbolize_names => true)
    end
#		puts "******* time to get_related_indicator_type_data: #{Time.now-start} seconds for event #{event_id}"
    return results
  end


  def self.csv_header
    "Event, Shape Type, Common ID, Common Name, Indicator, Value, Indicator, Value".split(",")
  end

  def self.download_header
		"#{I18n.t('models.datum.header.event')}, #{I18n.t('models.datum.header.map_level')}, #{I18n.t('models.datum.header.map_level_id')}, #{I18n.t('models.datum.header.map_level_name')}".split(",")
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

# get all of the data for a given event, shape and shape level
# NOTE - to reduce n+1 queries for getting translated text, all translations
#        are retrieved in the main query and obj.xxx_translations[0].name is used to
#        get the translations instead of the lazy method of obj.name which causes the n+1 queries
def self.get_table_data(event_id, shape_type_id, shape_id, indicator_id=nil, include_indicator_ids = false, pretty_data = false)
  if event_id.nil? || shape_type_id.nil? && shape_id.nil?
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
              :common_ids => shapes.collect(&:shape_common_id), :common_names => shapes.collect(&:shape_common_name))
            .order("indicator_types.sort_order asc, core_indicator_translations.name_abbrv ASC, datum_translations.common_name asc")
        else
logger.debug "=========== getting data for 1 indicator"
          # get data for provided indicator
          indicators = Indicator.includes({:event => :event_translations}, {:shape_type => :shape_type_translations}, {:core_indicator => [:core_indicator_translations, :indicator_type]}, {:data => :datum_translations})
            .where("indicators.id = :indicator_id and event_translations.locale = :locale and shape_type_translations.locale = :locale and core_indicator_translations.locale = :locale and datum_translations.locale = :locale and datum_translations.common_id in (:common_ids) and datum_translations.common_name in (:common_names)",
              :indicator_id => indicator_id, :locale => I18n.locale,
              :common_ids => shapes.collect(&:shape_common_id), :common_names => shapes.collect(&:shape_common_name))
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
					winner_col_header = ""
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
                row_starter << ind.shape_type.shape_type_translations[0].name_singular_possessive
              end
            end

            if ind.data.nil? || ind.data.empty?
  logger.debug "=========== no data"
              return nil
            else
              ind.data.each_with_index do |d, dindex|
                if ind.core_indicator.indicator_type.has_summary &&
                   (maxvalue[d.datum_translations[0].common_name].nil? ||
                   d.value.to_f > maxvalue[d.datum_translations[0].common_name])

                  maxvalue[d.datum_translations[0].common_name] = d.value.to_f
                  winner[d.datum_translations[0].common_name] = {:name => ind.core_indicator.core_indicator_translations[0].name,
										 :indicator_type_id => ind.core_indicator.indicator_type_id}
									winner_col_header = ind.core_indicator.indicator_type.summary_name if winner_col_header.empty?
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
                  row << d.datum_translations[0].common_id
                  # common name
                  row << d.datum_translations[0].common_name
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
          header << i.core_indicator.core_indicator_translations[0].description
          ind_ids << i.id
        end
        flattened = header[0].length
        indicator_type_ids = {}

        # add the rows
				# if an indicator type with a summary was found, add the winner column
				if winner.empty?
					# no winner column
		      ind_ids = ind_ids.flatten
		      data << header.flatten
		      rows.each do |r|
			      r = r[0..flattened-1] + r[flattened..-1]
		        data << r
		      end
				else
					# include winner column
		      ind_ids = ind_ids[0..0] + ['winner_ind'] + ind_ids[1..-1]
		      ind_ids = ind_ids.flatten
		      header = header[0..0] + [winner_col_header] + header[1..-1]
		      data << header.flatten
		      rows.each do |r|
			      # r[3] has to be the common_name
			      r = r[0..flattened-1] + [winner[r[3]][:name]] + r[flattened..-1]
			      indicator_type_ids[winner[r[3]][:name]] = winner[r[3]][:indicator_type_id]
		        data << r
		      end
				end
        return {:data => data, :indicator_ids => ind_ids, :indicator_type_ids => indicator_type_ids}
      end
    end
  end

	# get all of the data for the event in a csv format
	def self.get_all_data_for_event(event_id)
		data = []
		if event_id
			event = Event.find(event_id)
			shape_types = ShapeType.by_event(event_id)

			if event && shape_types && !shape_types.empty?
				shape_types.each_with_index do |shape_type, index|
					d = get_table_data(event_id, shape_type.id, event.shape_id )

					if d && !d.empty? && !d[:data].empty?
						if index == 0
							# keep the header row
							data << d[:data]
						else
							# header row already in data so skip it
							data << d[:data][1..-1]
						end
					end
				end
			end
		end
		return data.flatten(1)
	end


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
            data = Datum.select("id").where(["indicator_id in (:indicator_ids)",
								:indicator_ids => event.indicators.select("id").where(:id => indicator_id, :shape_type_id => shape_type_id).collect(&:id)])
						error1 = DatumTranslation.delete_all(["datum_id in (?)", data.collect(&:id)])
						error2 = Datum.delete_all(["id in (?)", data.collect(&:id)])
	          if error1 == 0 || error2 == 0
							msg = "error occurred while deleting records"
				      raise ActiveRecord::Rollback
							return msg
						end

					elsif !shape_type_id.nil?
logger.debug "------ delete data for shape type #{shape_type_id}"
						# delete all data assigned to shape_type
            data = Datum.select("id").where(["indicator_id in (:indicator_ids)",
								:indicator_ids => event.indicators.select("id").where(:shape_type_id => shape_type_id).collect(&:id)])
						error1 = DatumTranslation.delete_all(["datum_id in (?)", data.collect(&:id)])
						error2 = Datum.delete_all(["id in (?)", data.collect(&:id)])
	          if error1 == 0 || error2 == 0
							msg = "error occurred while deleting records"
				      raise ActiveRecord::Rollback
							return msg
						end

					else
logger.debug "------ delete all data for event #{event_id}"
						# delete all data for event
            data = Datum.select("id").where(["indicator_id in (:indicator_ids)",
								:indicator_ids => event.indicators.select("id").collect(&:id)])
						error1 = DatumTranslation.delete_all(["datum_id in (?)", data.collect(&:id)])
						error2 = Datum.delete_all(["id in (?)", data.collect(&:id)])
	          if error1 == 0 || error2 == 0
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

	# determine overall placement of value in array
	# assume array is already sorted in desired order
	# if tie, the rank will be adjusted:
	# if array 4,3,3,2,1,1
	#  - passing in value of 3 will return 2
	#  - passing in value of 2 will return 4
	#  - passing in value of 1 will return 5
	# returns hash {rank, total, has_duplicates}
	def self.compute_placement(data_ary, value)
		rank = nil
		total = nil
		has_duplicates = false

		if data_ary && !data_ary.empty? && value
			# find value in array
			index = data_ary.index{|x| x[:value] == value}

			if !index.nil?
				# get unique values and count of how many of each value in array
				unique = Hash.new(0)
				data_ary.each do |x|
					unique.store(x[:value], unique[x[:value]]+1)
				end
				# if unique length = data array length, no dups and can return placement
				if unique.length == data_ary.length
					rank = index+1
					total = data_ary.length
				else
					# duplicates exist
					has_duplicates = true
					rank = 0
					unique.each do |k,v|
						if k == value
							rank += 1
							break
						else
							rank += v
						end
					end
					# now determine the total records
					# if the last item is a duplicate, the total will be length - # of dups + 1
					if unique.to_a.last[1] > 1
						total = data_ary.length-unique.to_a.last[1] + 1
					else
						total = data_ary.length
					end
				end
			end
		end
		h = Hash.new()
		h[:rank] = rank
		h[:total] = total
		h[:has_duplicates] = has_duplicates
		return h;
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
	def indicator_description=(val)
		self[:indicator_description] = val
	end
	def indicator_description
		self[:indicator_description]
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
	def core_indicator_id=(val)
		self[:core_indicator_id] = val
	end
	def core_indicator_id
		self[:core_indicator_id]
	end
	def event_name=(val)
		self[:event_name] = val
	end
	def event_name
		self[:event_name]
	end
	def has_summary=(val)
		self[:has_summary] = val
	end
	def has_summary
		self[:has_summary]
	end
	def data_common_id=(val)
		self[:data_common_id] = val
	end
	def data_common_id
		self[:data_common_id]
	end
	def data_common_name=(val)
		self[:data_common_name] = val
	end
	def data_common_name
		self[:data_common_name]
	end

end
