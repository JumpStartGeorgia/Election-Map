class LiveDatum < ActiveRecord::Base
	require 'json_cache'
	require 'json'

  belongs_to :indicator

  attr_accessible :indicator_id, :live_dataset_id, :value,
			:en_common_id, :en_common_name, :ka_common_id, :ka_common_name

  validates :indicator_id, :live_dataset_id, :presence => true

  attr_accessor :number_format, :shape_id, :shape_type_name, :color,
		:indicator_name, :indicator_name_abbrv, :indicator_description,
		:indicator_type_id, :indicator_type_name, :core_indicator_id

	###################################
	## special gets for attributes
	###################################
  def common_id
    if read_attribute("#{I18n.locale}_common_id")
      return read_attribute("#{I18n.locale}_common_id")
    else
      return read_attribute("#{I18n.default_locale}_common_id")
    end
  end

  def common_name
    if read_attribute("#{I18n.locale}_common_name")
      return read_attribute("#{I18n.locale}_common_name")
    else
      return read_attribute("#{I18n.default_locale}_common_name")
    end
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

	def to_hash
		{
			:id => self.id,
			:value => self.value,
			:formatted_value => self.formatted_value,
			:number_format => self.number_format,
			:color => self[:color],
			:indicator_type_id => self[:indicator_type_id],
			:indicator_type_name => self[:indicator_type_name],
			:core_indicator_id => self[:core_indicator_id],
			:indicator_id => self[:indicator_id],
			:indicator_name => self[:indicator_name],
			:indicator_name_abbrv => self[:indicator_name_abbrv]
		}
	end

	###################################
	## get data
	###################################
	# get the data value for a shape and core indicator
	def self.get_data_for_shape_core_indicator(shape_id, event_id, shape_type_id, core_indicator_id)
    start = Time.now
    x = nil
		if !shape_id.nil? && !core_indicator_id.nil? && !event_id.nil? && !shape_type_id.nil?
			sql = "SELECT s.id as shape_id, i.id as indicator_id, i.core_indicator_id, ci.indicator_type_id, "
			sql << "d.id, d.value, ci.number_format as number_format, "
			sql << "if (ci.ancestry is null, cit.name, concat(cit.name, ' (', cit_parent.name_abbrv, ')')) as indicator_name, "
			sql << "if (ci.ancestry is null, cit.name_abbrv, concat(cit.name_abbrv, ' (', cit_parent.name_abbrv, ')')) as indicator_name_abbrv "
			sql << "FROM live_data as d  "
			sql << "inner join indicators as i on d.indicator_id = i.id  "
			sql << "inner join core_indicators as ci on i.core_indicator_id = ci.id  "
			sql << "inner join core_indicator_translations as cit on ci.id = cit.core_indicator_id "
			sql << "left join core_indicators as ci_parent on ci.ancestry = ci_parent.id  "
			sql << "left join core_indicator_translations as cit_parent on ci_parent.id = cit_parent.core_indicator_id AND cit_parent.locale = :locale "
			sql << "inner join shapes as s on i.shape_type_id = s.shape_type_id  "
			sql << "inner join shape_translations as st on s.id = st.shape_id and d.#{I18n.locale}_common_id = st.common_id and dt.#{I18n.locale}_common_name = st.common_name "
			sql << "WHERE i.event_id = :event_id AND i.shape_type_id = :shape_type_id AND i.core_indicator_id = :core_indicator_id "
			sql << "and s.id=:shape_id "
			sql << "AND cit.locale = :locale and st.locale = :locale "
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

			sql = "SELECT s.id as shape_id, i.id as indicator_id, i.core_indicator_id, ci.indicator_type_id, itt.name as indicator_type_name, "
			sql << "d.id, d.value, ci.number_format as number_format, "
			sql << "if (ci.ancestry is null, cit.name, concat(cit.name, ' (', cit_parent.name_abbrv, ')')) as indicator_name, "
			sql << "if (ci.ancestry is null, cit.name_abbrv, concat(cit.name_abbrv, ' (', cit_parent.name_abbrv, ')')) as indicator_name_abbrv, "
			sql << "if(ci.ancestry is null OR (ci.ancestry is not null AND (ci.color is not null AND length(ci.color)>0)),ci.color,ci_parent.color) as color "
			sql << "FROM live_data as d "
			sql << "inner join indicators as i on d.indicator_id = i.id "
			sql << "inner join core_indicators as ci on i.core_indicator_id = ci.id "
			sql << "inner join core_indicator_translations as cit on ci.id = cit.core_indicator_id "
			sql << "left join core_indicators as ci_parent on ci.ancestry = ci_parent.id "
			sql << "left join core_indicator_translations as cit_parent on ci_parent.id = cit_parent.core_indicator_id AND cit_parent.locale = :locale "
			sql << "inner join indicator_type_translations as itt on ci.indicator_type_id = itt.indicator_type_id "
			sql << "inner join shapes as s on i.shape_type_id = s.shape_type_id  "
			sql << "inner join shape_translations as st on s.id = st.shape_id and d.#{I18n.locale}_common_id = st.common_id and dt.#{I18n.locale}_common_name = st.common_name "
			sql << "WHERE i.event_id = :event_id and i.shape_type_id = :shape_type_id and ci.indicator_type_id = :indicator_type_id "
			sql << "and s.id=:shape_id "
			sql << "AND cit.locale = :locale AND itt.locale = :locale and st.locale = :locale "
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
  		              rank = LiveDatum.new
  		              rank.value = h[:rank].to_s
  		              rank["number_format"] = " / #{h[:total]}"
  		              rank["number_format"] += " *" if h[:has_duplicates]
  		              rank["indicator_type_name"] = data["summary_data"][index][:indicator_type_name]
  		              rank["indicator_name"] = I18n.t('app.common.overall_placement')
  		              rank["indicator_name_abbrv"] = I18n.t('app.common.overall_placement')
  		  						data_hash = Hash.new
  		  						data_hash["data_item"] = rank.to_hash
  		  	        	results << data_hash
                  end
								end

	              # add total # of indicators in the summary
	              rank = LiveDatum.new
	              rank.value = data["summary_data"].length
	              rank["indicator_type_name"] = data["summary_data"][index]["indicator_type_name"]
	              rank["indicator_name"] = I18n.t('app.common.total_participants')
	              rank["indicator_name_abbrv"] = I18n.t('app.common.total_participants')
	  						data_hash = Hash.new
	  						data_hash["data_item"] = rank.to_hash
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
  						data_hash["data_item"] = data.first.to_hash
  	        	results << data_hash
  					end
          end
        end
      end

      # add duplicate footnote if needed
      if has_duplicates
        footnote = LiveDatum.new
        footnote["indicator_name"] = "* #{I18n.t('app.common.footnote_duplicates')}"
        footnote["indicator_name_abbrv"] = "* #{I18n.t('app.common.footnote_duplicates')}"
				data_hash = Hash.new
				data_hash["footnote"] = footnote.to_hash
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
  				x = data.collect{|x| x.to_hash}
  			end
				x.to_json
  		}
			results["summary_data"] = JSON.parse(json,:symbolize_names => true)
    end
#		puts "******* time to get_related_indicator_type_data: #{Time.now-start} seconds for event #{event_id}"
    return results
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
		return h
	end


	###################################
	## load from csv
	###################################
  def self.build_from_csv(event_id, precincts_completed, precincts_total, timestamp, file)
		start = Time.now
    infile = file.read
    n, msg = 0, ""
    idx_event = 0
    idx_shape_type = 1
    idx_common_id = 2
    idx_common_name = 3
    index_first_ind = 4

		LiveDatum.transaction do
			# create the dataset record
			if event_id && precincts_completed && precincts_total && timestamp
				dataset = LiveDataSet.new
				dataset.event_id = event_id
				dataset.precincts_completed = precincts_completed
				dataset.precincts_total = precincts_total
				dataset.timestamp = timestamp
				if !dataset.save
  logger.debug "++++could not save the dataset"
    		  msg = I18n.t('models.live_dataset.msgs.dataset_not_save')
		      raise ActiveRecord::Rollback
          return msg
				end
			else
  logger.debug "++++params not supplied to save the dataset"
    		  msg = I18n.t('models.live_dataset.msgs.missing_params')
		      raise ActiveRecord::Rollback
          return msg
			end

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

          # if the event is not the same as the event passed into this method, stop
logger.debug "==========--------- event.nil? = #{event.nil?}; dataset.event_id = #{dataset.event_id}; event.id = #{event.id}"
          if event.nil? || dataset.event_id.to_s != event.id.to_s
    logger.debug "++++spreadsheet event does not match event selected on form"
      		  msg = I18n.t('models.live_dataset.msgs.events_not_match', :row_num => n)
  		      raise ActiveRecord::Rollback
            return msg
          end

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

								if indicator.nil? || indicator.empty?
				logger.debug "++++indicator was not found"
									msg = I18n.t('models.datum.msgs.indicator_not_found', :row_num => n)
									raise ActiveRecord::Rollback
									return msg
								else
				logger.debug "++++indicator found, saving record"
  		            startPhase = Time.now
  								# populate record
  								datum = LiveDatum.new
  								datum.live_dataset_id = dataset.id
  								datum.indicator_id = indicator.first.id
  								datum.value = row[i+1].strip if !row[i+1].nil? && row[i+1].downcase.strip != "null"
                  datum.en_common_id = row[idx_common_id].nil? ? row[idx_common_id] : row[idx_common_id].strip
                  datum.en_common_name = row[idx_common_name].nil? ? row[idx_common_name] : row[idx_common_name].strip
                  datum.ka_common_id = datum.en_common_id
                  datum.ka_common_name = datum.en_common_name
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
				end
			  puts "************ time to process row: #{Time.now-startRow} seconds"
			  puts "************************ total time so far : #{Time.now-start} seconds"
			end

  logger.debug "++++updating ka records with ka text in shape_names"
      startPhase = Time.now
			# ka translation is hardcoded as en in the code above
			# update all ka records with the apropriate ka translation
			# update common ids
			ActiveRecord::Base.connection.execute("update live_data as dt, shape_names as sn set dt.ka_common_id = sn.ka where dt.ka_common_id = sn.en")
			# update common names
			ActiveRecord::Base.connection.execute("update live_data as dt, shape_names as sn set dt.ka_common_name = sn.ka where dt.ka_common_name = sn.en")
      puts "************ time to update 'ka' common id and common name: #{Time.now-startPhase} seconds"
=begin this should only be done if dataset is marked as public
  logger.debug "++++updating event.has_live_data to true"
      dataset.event.has_live_data = true
      if !dataset.event.save
  logger.debug "++++ - error setting event.has_live_data "
		    msg = I18n.t('models.live_dataset.msgs.failed_set_event_flag')
		    raise ActiveRecord::Rollback
		    return msg
      end
=end
		end
    logger.debug "++++procssed #{n} rows in CSV file"
  	puts "****************** time to build_from_csv: #{Time.now-start} seconds"
    return msg
  end

end
