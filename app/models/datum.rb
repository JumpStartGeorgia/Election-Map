class Datum < ActiveRecord::Base
	require 'json_cache'
	require 'json'

  belongs_to :indicator

  attr_accessible :indicator_id, :data_set_id, :value,
			:en_common_id, :en_common_name, :ka_common_id, :ka_common_name

  validates :indicator_id, :data_set_id, :presence => true

  attr_accessor :number_format, :shape_id, :shape_type_name, :color,
		:indicator_name, :indicator_name_abbrv, :indicator_description,
		:indicator_type_id, :indicator_type_name, :core_indicator_id, :num_precincts,
		:visible

  DATA_TYPE = {:official => "official", :live => "live"}
	PRECINCTS_REPORTED = {:number => 'Precincts Reported (#)', :percent => 'Precincts Reported (%)'}
	FILE_CACHE_KEY_SUMMARY_DATA =
		"event_[event_id]/data_set_[data_set_id]/[locale]/summary_data/indicator_type_[indicator_type_id]/shape_type_[shape_type_id]/shape_[shape_id]"
#  	"summary_data/data_set_[data_set_id]/[locale]/indicator_type_[indicator_type_id]/shape_type_[shape_type_id]/shape_[shape_id]"


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
			:indicator_name_abbrv => self[:indicator_name_abbrv],
			:has_openlayers_rule_value => false,
			:visible => true
		}
	end


	def to_hash_data_table
		hash = Hash.new
		self.attributes.each do |k,v|
			hash[k] = v
		end
	end

	###################################
	## data queries
	###################################
	# get precincts reported for shape
	def self.get_precincts_reported_value(shape_id, event_id, data_set_id, indicator_name)
    x = nil
		if shape_id && event_id && data_set_id && indicator_name
			sql = "select d.value,ci.number_format,s.num_precincts "
			sql << "FROM data as d "
			sql << "inner join indicators as i on d.indicator_id = i.id  "
			sql << "inner join core_indicators as ci on i.core_indicator_id = ci.id  "
			sql << "inner join core_indicator_translations as cit on ci.id = cit.core_indicator_id "
			sql << "inner join shapes as s on i.shape_type_id = s.shape_type_id  "
			sql << "inner join shape_translations as st on s.id = st.shape_id and d.#{I18n.locale}_common_id = st.common_id and d.#{I18n.locale}_common_name = st.common_name "
			sql << "where "
			sql << "s.id = :shape_id "
			sql << "and i.event_id = :event_id "
			sql << "and d.data_set_id = :data_set_id "
			sql << "and cit.name = :indicator_name "
			sql << "and cit.locale = 'en' "
			sql << "and st.locale = :locale "

			x = find_by_sql([sql, :shape_id => shape_id, :event_id => event_id, :data_set_id => data_set_id,
					:indicator_name => indicator_name, :locale => I18n.locale])
		end
		return x
	end

	# get the data value for a shape and core indicator
	def self.get_data_for_shape_core_indicator(shape_id, event_id, shape_type_id, core_indicator_id, data_set_id)
    start = Time.now
    x = nil
		if !shape_id.nil? && !core_indicator_id.nil? && !event_id.nil? && !shape_type_id.nil? && !data_set_id.nil?
			sql = "SELECT s.id as shape_id, i.id as indicator_id, i.core_indicator_id, ci.indicator_type_id, "
			sql << "d.id, d.value, ci.number_format as number_format, "
			sql << "if (ci.ancestry is null, cit.name, concat(cit.name, ' (', cit_parent.name_abbrv, ')')) as indicator_name, "
			sql << "if (ci.ancestry is null, cit.name_abbrv, concat(cit.name_abbrv, ' (', cit_parent.name_abbrv, ')')) as indicator_name_abbrv "
			sql << "FROM data as d  "
			sql << "inner join indicators as i on d.indicator_id = i.id  "
			sql << "inner join core_indicators as ci on i.core_indicator_id = ci.id  "
			sql << "inner join core_indicator_translations as cit on ci.id = cit.core_indicator_id "
			sql << "left join core_indicators as ci_parent on ci.ancestry = ci_parent.id  "
			sql << "left join core_indicator_translations as cit_parent on ci_parent.id = cit_parent.core_indicator_id AND cit_parent.locale = :locale "
			sql << "inner join shapes as s on i.shape_type_id = s.shape_type_id  "
			sql << "inner join shape_translations as st on s.id = st.shape_id and d.#{I18n.locale}_common_id = st.common_id and d.#{I18n.locale}_common_name = st.common_name "
			sql << "WHERE i.event_id = :event_id AND i.shape_type_id = :shape_type_id AND i.core_indicator_id = :core_indicator_id "
			sql << "and s.id=:shape_id and d.data_set_id = :data_set_id "
			sql << "AND cit.locale = :locale and st.locale = :locale "
      sql << "order by s.id asc "
			x = find_by_sql([sql, :core_indicator_id => core_indicator_id, :event_id => event_id,
			                  :shape_id => shape_id, :data_set_id => data_set_id,
			                  :shape_type_id => shape_type_id, :locale => I18n.locale])
		end
#		puts "********************* time to query data for core indicator: #{Time.now-start} seconds for event #{event_id} and core indicator #{core_indicator_id} - # of results = #{x.length}"
    return x
	end

	# get the max data value for all indicators that belong to the
	# indicator type and event for a specific shape

	def self.get_summary_data_for_shape(shape_id, event_id, shape_type_id, indicator_type_id, data_set_id, limit=nil)

    start = Time.now
    x = nil
		if !shape_id.nil? && !event_id.nil? && !indicator_type_id.nil? && !shape_type_id.nil? && !data_set_id.nil?
		  # if limit is a string, convert to int
		  # will be string if value passed in via params object
	    limit = limit.to_i if !limit.nil? && limit.class == String

			sql = "SELECT s.id as shape_id, i.id as indicator_id, i.core_indicator_id, ci.indicator_type_id, itt.name as indicator_type_name, "
			sql << "d.id, d.value, ci.number_format as number_format, "
			sql << "if (ci.ancestry is null, cit.name, concat(cit.name, ' (', cit_parent.name_abbrv, ')')) as indicator_name, "
			sql << "if (ci.ancestry is null, cit.name_abbrv, concat(cit.name_abbrv, ' (', cit_parent.name_abbrv, ')')) as indicator_name_abbrv, "
			sql << "if(ci.ancestry is null OR (ci.ancestry is not null AND (ci.color is not null AND length(ci.color)>0)),ci.color,ci_parent.color) as color "
			sql << "FROM data as d "
			sql << "inner join indicators as i on d.indicator_id = i.id "
			sql << "inner join core_indicators as ci on i.core_indicator_id = ci.id "
			sql << "inner join core_indicator_translations as cit on ci.id = cit.core_indicator_id "
			sql << "left join core_indicators as ci_parent on ci.ancestry = ci_parent.id "
			sql << "left join core_indicator_translations as cit_parent on ci_parent.id = cit_parent.core_indicator_id AND cit_parent.locale = :locale "
			sql << "inner join indicator_type_translations as itt on ci.indicator_type_id = itt.indicator_type_id "
			sql << "inner join shapes as s on i.shape_type_id = s.shape_type_id  "
			sql << "inner join shape_translations as st on s.id = st.shape_id and d.#{I18n.locale}_common_id = st.common_id and d.#{I18n.locale}_common_name = st.common_name "
			sql << "WHERE i.event_id = :event_id and i.shape_type_id = :shape_type_id and ci.indicator_type_id = :indicator_type_id "
			sql << "and s.id=:shape_id  and d.data_set_id = :data_set_id "
			sql << "AND cit.locale = :locale AND itt.locale = :locale and st.locale = :locale "
      sql << "order by s.id asc, d.value desc "
      sql << "limit :limit" if !limit.nil?
			x = find_by_sql([sql, :event_id => event_id, :shape_type_id => shape_type_id,
			                  :shape_id => shape_id, :data_set_id => data_set_id,
			                  :indicator_type_id => indicator_type_id, :locale => I18n.locale, :limit => limit])

		end
#		puts "********************* time to query summary data for indicator type: #{Time.now-start} seconds for event #{event_id} and indicator type #{indicator_type_id} - # of results = #{x.length}"
    return x
	end


	###################################
	## get data
	###################################
	def self.get_precincts_reported(shape_id, event_id, data_set_id)
		hash = nil
		if shape_id && event_id && data_set_id
			num = get_precincts_reported_value(shape_id, event_id, data_set_id, Datum::PRECINCTS_REPORTED[:number])
			perc = get_precincts_reported_value(shape_id, event_id, data_set_id, Datum::PRECINCTS_REPORTED[:percent])

			if num && !num.empty? && perc && !perc.empty?
				hash = Hash.new
				hash[:num_precincts] = ActionController::Base.helpers.number_with_delimiter(num.first["num_precincts"])
				hash[:completed_number] = num.first.formatted_value
				hash[:completed_percent] = ActionController::Base.helpers.number_to_percentage(perc.first.formatted_value)
			end
		end
		return hash
	end

	def self.build_summary_json(shape_id, shape_type_id, event_id, indicator_type_id, data_set_id)
		start = Time.now
    results = Hash.new
		if shape_id.present? && shape_type_id.present? && event_id.present? && indicator_type_id.present? && data_set_id.present?
      # get the shapes
		  shapes = Shape.get_shapes_by_type(shape_id, shape_type_id, false)

  	  # get the event
  	  event = Event.find(event_id)

  	  # get indicator type
  	  indicator_type = IndicatorType.find(indicator_type_id)

      # add info about this data
  	  # add the indicator info
  	  results["indicator"] = Hash.new
      results["indicator"]["name"] = nil
			results["indicator"]["name_abbrv"] = indicator_type.nil? ? nil : indicator_type.summary_name
			results["indicator"]["description"] = nil
			results["indicator"]["number_format"] = nil
      results["indicator"]["scales"] = [{:name => IndicatorScale::NO_DATA_TEXT, :color => IndicatorScale::NO_DATA_COLOR }]
			results["indicator"]["scale_colors"] = [IndicatorScale::NO_DATA_COLOR]
			results["indicator"]["switcher_indicator_id"] = nil

      # indicate this is summary data
      results["view_type"] = "summary"

      # add the data
      results["shape_data"] = []

      if shapes && !shapes.empty? && event
        shapes.each do |shape|
      	  # get all of the related json data for this indicator type
      	  data = build_related_indicator_json2(shape.id, shape_type_id, event_id, data_set_id,
      	    event.event_indicator_relationships.where(:indicator_type_id => indicator_type_id))

          summary = data.select{|x| x.has_key?("summary_data") && x["summary_data"].present? &&
                      x["summary_data"]["data"][0][:indicator_type_id].to_s == indicator_type_id.to_s &&
    									x["summary_data"]["data"][0][:formatted_value] != I18n.t('app.msgs.no_data')}
          if summary.present?
            shape_values = data.select{|x| x.has_key?("shape_values") && x["shape_values"].present?}
            if shape_values.present?
Rails.logger.debug "++++++++++++++++++++shape parent id = #{shape.parent_id}"
              shape_values.first["shape_values"]["parent_id"] = shape.parent_id
              shape_values.first["shape_values"]["value"] = summary.first["summary_data"]["data"].first[:indicator_name_abbrv]
              shape_values.first["shape_values"]["color"] = summary.first["summary_data"]["data"].first[:color]
              shape_values.first["shape_values"]["title"] = summary.first["summary_data"]["data"].first[:summary_name]
            end
          end

          # save the data
      	  results["shape_data"] << data
  	    end
  	  end
    end
#		puts "******* time to get_related_indicator_type_data: #{Time.now-start} seconds for event #{event_id}"
    return results
  end

	def self.build_json(shape_id, shape_type_id, indicator_id, data_set_id)
		start = Time.new
    results = Hash.new
		if shape_id.present? && shape_type_id.present? && indicator_id.present? && data_set_id.present?
      # get the shapes
		  shapes = Shape.get_shapes_by_type(shape_id, shape_type_id, false)

			# get the indicator
			indicator = Indicator.find(indicator_id)

      # add info about this data
  	  # add the indicator info
  	  results["indicator"] = Hash.new
      results["indicator"]["name"] = indicator.name
			results["indicator"]["name_abbrv"] = indicator.name_abbrv_w_parent
			results["indicator"]["description"] = indicator.description_w_parent
			results["indicator"]["number_format"] = indicator.number_format.nil? ? "" : indicator.number_format
      results["indicator"]["scales"] = IndicatorScale.for_indicator(indicator.id)
			results["indicator"]["scale_colors"] = IndicatorScale.get_colors(indicator.id)
			results["indicator"]["switcher_indicator_id"] = nil

			# if this event has a custom view at this level, get indicator id for other shape live
			new_indicator = nil
			custom_view = indicator.event.event_custom_views.where(:shape_type_id => shape_type_id)
			if custom_view.present?
				new_indicator = Indicator.find_new_id(indicator_id, custom_view.first.descendant_shape_type_id)
			else
				custom_view = indicator.event.event_custom_views.where(:descendant_shape_type_id => shape_type_id)
  			if custom_view.present?
					new_indicator = Indicator.find_new_id(indicator_id, custom_view.first.shape_type.child_ids.first)
				end
			end
			if new_indicator
				# is custom view, update switcher indicator id
				results["indicator"]["switcher_indicator_id"] = new_indicator.id
			end

      # indicate this is not summary data
      results["view_type"] = "normal"

      # add the data
      results["shape_data"] = []

      if shapes.present? && indicator.present?
  			event = indicator.event
        shapes.each do |shape|
      	  # get all of the related json data for this indicator
      	  data = build_related_indicator_json2(shape.id, shape_type_id, event.id, data_set_id,
      	    event.event_indicator_relationships.where(:core_indicator_id => indicator.core_indicator_id))

      	  # find the data item with the indicator_id and use it's values to set the shape_values hash
          data_item = data.select{|x| x.has_key?("data_item") && x["data_item"].present? &&
                        x["data_item"][:indicator_id].to_s == indicator_id.to_s}
          if data_item.present?
            shape_values = data.select{|x| x.has_key?("shape_values") && x["shape_values"].present?}
            if shape_values.present?
Rails.logger.debug "++++++++++++++++++++shape parent id = #{shape.parent_id}"
              shape_values.first["shape_values"]["parent_id"] = shape.parent_id
              shape_values.first["shape_values"]["value"] = data_item.first["data_item"][:value]
              shape_values.first["shape_values"]["number_format"] = data_item.first["data_item"][:number_format]
              shape_values.first["shape_values"]["title"] = data_item.first["data_item"][:indicator_name]
              shape_values.first["shape_values"]["title_abbrv"] = data_item.first["data_item"][:indicator_name_abbrv]
            end
          end

          # save the data
      	  results["shape_data"] << data
        end
      end
    end
#		puts "******* time to get_related_indicator_data: #{Time.now-start} seconds for indicator #{indicator_id}"
    return results
  end

  # build the json string for the provided indicator relationships
  # [
  #    {shape_values => {}}
  #    {"summary_data" => []}
  #    {"data_item" => {}}
  #    {"footnote" => {}}
  # ]
	def self.build_related_indicator_json2(shape_id, shape_type_id, event_id, data_set_id, relationships)
    results = []

    # create empty shape_values hash
    # - these values will be pushed into the shape json file so they
    #    can be color coded by openlayers
    # - will be populated with real value by the method that called this method
    shape_values = Hash.new
	  shape_values["shape_id"] = shape_id
	  shape_values["parent_id"] = nil
	  shape_values["value"] = I18n.t('app.msgs.no_data')
	  shape_values["color"] = nil
	  shape_values["number_format"] = nil
	  shape_values["title"] = I18n.t('app.msgs.no_data')
	  shape_values["title_abbrv"] = nil
	  shape_values["title_location"] = nil
    data_hash = Hash.new
		data_hash["shape_values"] = shape_values
	  results << data_hash

	  if shape_id.present? && event_id.present? && shape_type_id.present? && data_set_id.present? && relationships.present?
      has_duplicates = false
	    relationships.each do |rel|
	      if rel.related_indicator_type_id.present?
	        # get the summary for this indciator type
					data = build_summary_data_json(shape_id, shape_type_id, event_id, rel.related_indicator_type_id, data_set_id)
					if data.present? && data["summary_data"].present? && data["summary_data"]["data"].present?
	        	results << data
					end
        elsif rel.related_core_indicator_id.present?
          # see if indicator is part of indicator type that has summary
          # if so, get the summary info so can assign the overall placement and overall winner
          core = CoreIndicator.get_indicator_type_with_summary(rel.related_core_indicator_id)
          if core.present?
            # get summary data
  					data = build_summary_data_json(shape_id, shape_type_id, event_id, core.indicator_type_id, data_set_id)
  					if data.present? && data["summary_data"].present? && data["summary_data"]["data"].present?
              # add the data item for the provided indicator
              index = data["summary_data"]["data"].index{|x| x[:core_indicator_id] == rel.related_core_indicator_id}
              if index
    						data_hash = Hash.new
    						data_hash["data_item"] = data["summary_data"]["data"][index]
								data_hash["data_item"][:visible] = rel.visible
								data_hash["data_item"][:has_openlayers_rule_value] = rel.has_openlayers_rule_value
    	        	results << data_hash

                # add the placement of this indicator
								# if value != no data
								# if there are duplicate values (e.g., a tie) fix the rank accordingly
								if data["summary_data"]["data"][index][:value] != I18n.t('app.msgs.no_data')
								  #&& data["summary_data"][index][:value] != "0"

                  # returns {:rank, :total, :has_duplicates}
                  h = compute_placement(data["summary_data"]["data"], data["summary_data"]["data"][index][:value])
                  has_duplicates = h[:has_duplicates]
                  if h.present?
  		              rank = Datum.new
  		              rank.value = h[:rank].to_s
  		              rank["number_format"] = " / #{h[:total]}"
  		              rank["number_format"] += " *" if h[:has_duplicates]
  		              rank["indicator_type_name"] = data["summary_data"]["data"][index][:indicator_type_name]
  		              rank["indicator_name"] = I18n.t('app.common.overall_placement')
  		              rank["indicator_name_abbrv"] = I18n.t('app.common.overall_placement')
  		  						data_hash = Hash.new
  		  						data_hash["data_item"] = rank.to_hash
  		  	        	results << data_hash
                  end
								end

	              # add total # of indicators in the summary
	              rank = Datum.new
	              rank.value = data["summary_data"]["data"].length
	              rank["indicator_type_name"] = data["summary_data"]["data"][index]["indicator_type_name"]
	              rank["indicator_name"] = I18n.t('app.common.total_participants')
	              rank["indicator_name_abbrv"] = I18n.t('app.common.total_participants')
	  						data_hash = Hash.new
	  						data_hash["data_item"] = rank.to_hash
	  	        	results << data_hash
              end

              # add the winner if this record is not it and if value != no data or 0
							if index > 0 &&
									data["summary_data"]["data"][0][:value] != "0" &&
									data["summary_data"]["data"][0][:value] != I18n.t('app.msgs.no_data')

                data["summary_data"]["data"][0][:indicator_name].insert(0, "#{I18n.t('app.common.winner')}: ")
                data["summary_data"]["data"][0][:indicator_name_abbrv].insert(0, "#{I18n.t('app.common.winner')}: ")
    						data_hash = Hash.new
    						data_hash["data_item"] = data["summary_data"]["data"][0]
    	        	results << data_hash
              end
  					end
          else
            # indicator type does not have summary
            # get the data item for this indciator
  					data = get_data_for_shape_core_indicator(shape_id, event_id, shape_type_id, rel.related_core_indicator_id, data_set_id)
  					if data && !data.empty?
  						data_hash = Hash.new
  						data_hash["data_item"] = data.first.to_hash
							data_hash["data_item"][:visible] = rel.visible
							data_hash["data_item"][:has_openlayers_rule_value] = rel.has_openlayers_rule_value
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
				data_hash["footnote"] = footnote.to_hash
      	results << data_hash
      end
    end
	  return results
  end

##############################
############################## old start
##############################
	def self.get_related_indicator_type_data(shape_id, shape_type_id, event_id, indicator_type_id, data_set_id)
		start = Time.now
    results = nil
		if !shape_id.nil? && !shape_type_id.nil? && !event_id.nil? && !indicator_type_id.nil? && !data_set_id.nil?

  	  # get the event
  	  event = Event.find(event_id)
  	  # get the relationships for this indicator type
  	  results = build_related_indicator_json(shape_id, shape_type_id, event_id, data_set_id,
  	    event.event_indicator_relationships.where(:indicator_type_id => indicator_type_id))
    end
		#logger.debug "******* time to get_related_indicator_type_data: #{Time.now-start} seconds for event #{event_id}"
    return results
  end

	def self.get_related_indicator_data(shape_id, indicator_id, data_set_id)
		start = Time.new
    results = nil
		if !shape_id.nil? && !indicator_id.nil? && !data_set_id.nil?
			# get the indicator
			indicator = Indicator.find(indicator_id)
			event = indicator.event

  	  # get the relationships for this indicator
  	  results = build_related_indicator_json(shape_id, indicator.shape_type_id, event.id, data_set_id,
  	    event.event_indicator_relationships.where(:core_indicator_id => indicator.core_indicator_id))
    end
		#logger.debug "******* time to get_related_indicator_data: #{Time.now-start} seconds for indicator #{indicator_id}"
    return results
  end

	def self.get_related_core_indicator_data(shape_id, shape_type_id, event_id, core_indicator_id, data_set_id)
		start = Time.now
    results = nil
		if !shape_id.nil? && !shape_type_id.nil? && !event_id.nil? && !core_indicator_id.nil? && !data_set_id.nil?
  	  # get the event
  	  event = Event.find(event_id)

  	  # get the relationships for this indicator
  	  results = build_related_indicator_json(shape_id, shape_type_id, event_id, data_set_id,
  	    event.event_indicator_relationships.where(:core_indicator_id => core_indicator_id))
    end
		#logger.debug "****************** time to get_related_core_indicator_data: #{Time.now-start} seconds for event #{event_id} and core indicator #{core_indicator_id}"
    return results
  end

  # build the json string for the provided indicator relationships
	def self.build_related_indicator_json(shape_id, shape_type_id, event_id, data_set_id, relationships)
    results = []
	  if !shape_id.nil? && !event_id.nil? && !shape_type_id.nil? && !data_set_id.nil? &&
	        !relationships.nil? && !relationships.empty?
      has_duplicates = false
	    relationships.each do |rel|
	      if !rel.related_indicator_type_id.nil?
	        # get the summary for this indciator type
					data = get_indicator_type_data(shape_id, shape_type_id, event_id, rel.related_indicator_type_id, data_set_id)
					if data && !data["summary_data"].empty? && !data["summary_data"]["data"].empty?
	        	results << data
					end
        elsif !rel.related_core_indicator_id.nil?
          # see if indicator is part of indicator type that has summary
          # if so, get the summary info so can assign the overall placement and overall winner
          core = CoreIndicator.get_indicator_type_with_summary(rel.related_core_indicator_id)
          if core
            # get summary data
  					data = get_indicator_type_data(shape_id, shape_type_id, event_id, core.indicator_type_id, data_set_id)
  					if data && !data["summary_data"].empty? && !data["summary_data"]["data"].empty?
              # add the data item for the provided indicator
              index = data["summary_data"]["data"].index{|x| x[:core_indicator_id] == rel.related_core_indicator_id}
              if index
    						data_hash = Hash.new
    						data_hash["data_item"] = data["summary_data"]["data"][index]
								data_hash["data_item"][:visible] = rel.visible
								data_hash["data_item"][:has_openlayers_rule_value] = rel.has_openlayers_rule_value
    	        	results << data_hash

                # add the placement of this indicator
								# if value != no data
								# if there are duplicate values (e.g., a tie) fix the rank accordingly
								if data["summary_data"]["data"][index][:value] != I18n.t('app.msgs.no_data')
								  #&& data["summary_data"][index][:value] != "0"

                  # returns {:rank, :total, :has_duplicates}
                  h = compute_placement(data["summary_data"]["data"], data["summary_data"]["data"][index][:value])
                  has_duplicates = h[:has_duplicates]
                  if !h.nil? && !h.empty?
  		              rank = Datum.new
  		              rank.value = h[:rank].to_s
  		              rank["number_format"] = " / #{h[:total]}"
  		              rank["number_format"] += " *" if h[:has_duplicates]
  		              rank["indicator_type_name"] = data["summary_data"]["data"][index][:indicator_type_name]
  		              rank["indicator_name"] = I18n.t('app.common.overall_placement')
  		              rank["indicator_name_abbrv"] = I18n.t('app.common.overall_placement')
  		  						data_hash = Hash.new
  		  						data_hash["data_item"] = rank.to_hash
  		  	        	results << data_hash
                  end
								end

	              # add total # of indicators in the summary
	              rank = Datum.new
	              rank.value = data["summary_data"]["data"].length
	              rank["indicator_type_name"] = data["summary_data"]["data"][index]["indicator_type_name"]
	              rank["indicator_name"] = I18n.t('app.common.total_participants')
	              rank["indicator_name_abbrv"] = I18n.t('app.common.total_participants')
	  						data_hash = Hash.new
	  						data_hash["data_item"] = rank.to_hash
	  	        	results << data_hash
              end

              # add the winner if this record is not it and if value != no data or 0
							if index > 0 &&
									data["summary_data"]["data"][0][:value] != "0" &&
									data["summary_data"]["data"][0][:value] != I18n.t('app.msgs.no_data')

                data["summary_data"]["data"][0][:indicator_name].insert(0, "#{I18n.t('app.common.winner')}: ")
                data["summary_data"]["data"][0][:indicator_name_abbrv].insert(0, "#{I18n.t('app.common.winner')}: ")
    						data_hash = Hash.new
    						data_hash["data_item"] = data["summary_data"]["data"][0]
    	        	results << data_hash
              end
  					end
          else
            # indicator type does not have summary
            # get the data item for this indciator
  					data = get_data_for_shape_core_indicator(shape_id, event_id, shape_type_id, rel.related_core_indicator_id, data_set_id)
  					if data && !data.empty?
  						data_hash = Hash.new
  						data_hash["data_item"] = data.first.to_hash
							data_hash["data_item"][:visible] = rel.visible
							data_hash["data_item"][:has_openlayers_rule_value] = rel.has_openlayers_rule_value
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
				data_hash["footnote"] = footnote.to_hash
      	results << data_hash
      end
    end
	  return results
  end

##############################
############################## old end
##############################


  # get the summary data for an indicator type in an event for a shape
	def self.build_summary_data_json(shape_id, shape_type_id, event_id, indicator_type_id, data_set_id)
		start = Time.now
		results = Hash.new
		results["summary_data"] = Hash.new
		results["summary_data"]["data"] = []
		results["summary_data"]["visible"] = true
		results["summary_data"]["has_openlayers_rule_value"] = false

		if shape_id.present? && shape_type_id.present? && event_id.present? && indicator_type_id.present? && data_set_id.present?
			json = []
  		key = FILE_CACHE_KEY_SUMMARY_DATA.gsub("[shape_id]", shape_id.to_s)
					.gsub("[locale]", I18n.locale.to_s)
		      .gsub("[event_id]", event_id.to_s)
		      .gsub("[indicator_type_id]", indicator_type_id.to_s)
		      .gsub("[shape_type_id]", shape_type_id.to_s)
		      .gsub("[data_set_id]", data_set_id.to_s)

  		json = JSON.parse(JsonCache.fetch_data(key) {
				relationship = EventIndicatorRelationship.where(:event_id => event_id,
					:indicator_type_id => indicator_type_id,
					:related_indicator_type_id => indicator_type_id)
  			data = get_summary_data_for_shape(shape_id, event_id, shape_type_id, indicator_type_id, data_set_id)
        hash = Hash.new()
        hash["data"] = []
        hash["visible"] = true
        hash["has_openlayers_rule_value"] = false

  			if !data.blank?
logger.debug "************* getting summary data relationship params ****************"
					if !relationship.blank?
logger.debug "************* - visible = #{relationship.first.visible}"
logger.debug "************* - has_openlayers_rule_value = #{relationship.first.has_openlayers_rule_value}"
            hash["visible"] = relationship.first.visible
            hash["has_openlayers_rule_value"] = relationship.first.has_openlayers_rule_value
					end

  				hash["data"] = data.collect{|x|	x.to_hash}
  			end
logger.debug "*****************************"
				hash.to_json
  		})

      # update summary data flags
logger.debug "************* json keys = #{json.keys}"
logger.debug "************* visible flag from cache = #{json['visible']}"
logger.debug "************* has_openlayers_rule_value flag from cache = #{json['has_openlayers_rule_value']}"
			results["summary_data"]["visible"] = json['visible']
			results["summary_data"]["has_openlayers_rule_value"] = json['has_openlayers_rule_value']
      # add summary data
			results["summary_data"]["data"] = json['data'].map{|x| x.symbolize_keys}
    end
#		puts "******* time to get_related_indicator_type_data: #{Time.now-start} seconds for event #{event_id}"
    return results
  end

##############################
############################## old start
##############################
  # get the summary data for an indicator type in an event for a shape
	def self.get_indicator_type_data(shape_id, shape_type_id, event_id, indicator_type_id, data_set_id)
		start = Time.now
		results = Hash.new
		results["summary_data"] = Hash.new
		results["summary_data"]["data"] = []
		results["summary_data"]["visible"] = true
		results["summary_data"]["has_openlayers_rule_value"] = false

		if !shape_id.nil? && !shape_type_id.nil? && !event_id.nil? && !indicator_type_id.nil? && !data_set_id.nil?
			json = []
  		key = "summary_data/data_set_#{data_set_id}/#{I18n.locale}/indicator_type_#{indicator_type_id}/shape_type_#{shape_type_id}/shape_#{shape_id}"

  		json = JSON.parse(JsonCache.fetch(event_id, key) {
				relationship = EventIndicatorRelationship.where(:event_id => event_id,
					:indicator_type_id => indicator_type_id,
					:related_indicator_type_id => indicator_type_id)
  			data = get_summary_data_for_shape(shape_id, event_id, shape_type_id, indicator_type_id, data_set_id)
        hash = Hash.new()
        hash["data"] = []
        hash["visible"] = true
        hash["has_openlayers_rule_value"] = false

  			if !data.blank?
logger.debug "************* getting summary data relationship params ****************"
					if !relationship.blank?
logger.debug "************* - visible = #{relationship.first.visible}"
logger.debug "************* - has_openlayers_rule_value = #{relationship.first.has_openlayers_rule_value}"
            hash["visible"] = relationship.first.visible
            hash["has_openlayers_rule_value"] = relationship.first.has_openlayers_rule_value
					end

  				hash["data"] = data.collect{|x|	x.to_hash}
  			end
logger.debug "*****************************"
				hash.to_json
  		})

      # update summary data flags
logger.debug "************* json keys = #{json.keys}"
logger.debug "************* visible flag from cache = #{json['visible']}"
logger.debug "************* has_openlayers_rule_value flag from cache = #{json['has_openlayers_rule_value']}"
			results["summary_data"]["visible"] = json['visible']
			results["summary_data"]["has_openlayers_rule_value"] = json['has_openlayers_rule_value']
      # add summary data
			results["summary_data"]["data"] = json['data'].map{|x| x.symbolize_keys}
    end
#		puts "******* time to get_related_indicator_type_data: #{Time.now-start} seconds for event #{event_id}"
    return results
  end
##############################
############################## old end
##############################

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
  def self.csv_header
    "Shape Type, Common ID, Common Name, Indicator1, Indicator2, Indicator3".split(",")
  end

  def self.download_header
		"#{I18n.t('models.datum.header.event')}, #{I18n.t('models.datum.header.map_level')}, #{I18n.t('models.datum.header.map_level_id')}, #{I18n.t('models.datum.header.map_level_name')}".split(",")
  end

  # csv must have the columns listed in csv_header var
  #
  def self.build_from_csv(event_id, data_type, precincts_completed, precincts_total, timestamp, file)
		start = Time.now
    infile = file.read
    n, msg = 0, ""
    event = nil
    shape_types = nil
    indicators = []
    idx_shape_type = 0
    idx_common_id = 1
    idx_common_name = 2
    index_first_ind = 3
		original_locale = I18n.locale
    I18n.locale = :en

		Datum.transaction do
			# create the dataset record
			if event_id && data_type && timestamp
				dataset = DataSet.new
				dataset.event_id = event_id
				dataset.data_type = data_type
				dataset.precincts_completed = precincts_completed
				dataset.precincts_total = precincts_total
				dataset.timestamp = timestamp
				if !dataset.save
  #logger.debug "++++could not save the dataset"
    		  msg = I18n.t('models.data_set.msgs.dataset_not_save')
		      raise ActiveRecord::Rollback
          return msg
				end
			else
  #logger.debug "++++params not supplied to save the dataset"
    		  msg = I18n.t('models.data_set.msgs.missing_params')
		      raise ActiveRecord::Rollback
          return msg
			end

		  CSV.parse(infile) do |row|
        startRow = Time.now
		    n += 1
  puts "@@@@@@@@@@@@@@@@@@ processing row #{n}"
        if n == 1
          # get the event
					event = Event.find(event_id)

					if event.nil?
			#logger.debug "++++event or shape type was not found"
		  		  msg = I18n.t('models.datum.msgs.no_event_db')
				    raise ActiveRecord::Rollback
		  		  return msg
          end

          # get all shape types now instead of doing a query for every row
#logger.debug "****************getting all shape types"
          shape_types = ShapeType.all

          # get the indicators for all shape types
#logger.debug "****************getting all indicators between columns #{index_first_ind} and #{row.length-1}"
          (index_first_ind..row.length-1).each do |ind_index|
#logger.debug "****************indicator index = #{ind_index}"
  					indicator = Indicator.select("indicators.id, indicators.shape_type_id")
  						.includes(:core_indicator => :core_indicator_translations)
  						.where('indicators.event_id=:event_id and core_indicator_translations.locale=:locale and core_indicator_translations.name=:name',
  							:event_id => event.id, :name => row[ind_index], :locale => "en")

            if !indicator || indicator.empty?
              # indicator not found
		#logger.debug "++++indicator was not found"
							msg = I18n.t('models.datum.msgs.indicator_not_found', :name => row[ind_index])
							raise ActiveRecord::Rollback
							return msg
            else
              # save the indciator
              indicators << indicator
            end
          end

          # go to the next row
		      next
        end


        if row[idx_shape_type].nil? || row[idx_shape_type].strip.length == 0
  #logger.debug "++++shape type was not found in spreadsheet"
    		  msg = I18n.t('models.datum.msgs.no_shape_spreadsheet', :row_num => n)
		      raise ActiveRecord::Rollback
          return msg
				end

				# get the shape type id
				shape_type = shape_types.select{|x| x.name_singular == row[idx_shape_type].strip}

				if shape_type.nil? || shape_type.empty?
		#logger.debug "++++ shape type was not found"
	  		  msg = I18n.t('models.datum.msgs.no_shape_db', :row_num => n)
			    raise ActiveRecord::Rollback
	  		  return msg
	  		end

	  		shape_type = shape_type.first

	#logger.debug "++++shape found, checking for common values"
        if row[idx_common_id].nil? || row[idx_common_name].nil?
    		  msg = I18n.t('models.datum.msgs.missing_data_spreadsheet', :row_num => n)
#logger.debug "++++**missing data in row"
          raise ActiveRecord::Rollback
          return msg
	      end

	#logger.debug "++++ common values found, processing indicators"
				i = index_first_ind
        (index_first_ind..row.length-1).each do |ind_index|
          if !row[ind_index].nil?
            # get the indicator
            indicator = indicators[ind_index-index_first_ind].select{|x| x.shape_type_id == shape_type.id}

						has_no_data_value = row[ind_index].empty? || row[ind_index].downcase.strip == "null" ||
							row[ind_index].downcase.strip == I18n.t('app.msgs.no_data') ||
							row[ind_index].strip == "\\N"

						if (indicator.nil? || indicator.empty?)
							if !has_no_data_value
			#logger.debug "++++indicator was not found"
								msg = I18n.t('models.datum.msgs.indicator_not_found_with_data',
									:row_num => n, :name => indicators[ind_index-index_first_ind].first.name)
								raise ActiveRecord::Rollback
								return msg
							end
						else
		          # save the data record
							datum = Datum.new
							datum.data_set_id = dataset.id
							datum.indicator_id = indicator.first.id
		          if has_no_data_value
								datum.value = nil
							else
								datum.value = row[ind_index].strip
							end
		          datum.en_common_id = row[idx_common_id].nil? ? row[idx_common_id] : row[idx_common_id].strip
		          datum.en_common_name = row[idx_common_name].nil? ? row[idx_common_name] : row[idx_common_name].strip
		          datum.ka_common_id = datum.en_common_id
		          datum.ka_common_name = datum.en_common_name

							if datum.valid?
								datum.save
							else
								# an error occurred, stop
							  msg = I18n.t('models.datum.msgs.not_valid', :row_num => n)
							  raise ActiveRecord::Rollback
							  return msg
							end
						end
          end
        end
      	puts "******** time to process row: #{Time.now-startRow} seconds"
	      puts "************************ total time so far : #{Time.now-start} seconds"
      end

  #logger.debug "++++updating ka records with ka text in shape_names"
      startPhase = Time.now
			# ka translation is hardcoded as en in the code above
			# update all ka records with the apropriate ka translation
			# update common ids
			ActiveRecord::Base.connection.execute("update data as dt, shape_names as sn set dt.ka_common_id = sn.ka where dt.ka_common_id = sn.en and dt.data_set_id = #{dataset.id}")
			# update common names
			ActiveRecord::Base.connection.execute("update data as dt, shape_names as sn set dt.ka_common_name = sn.ka where dt.ka_common_name = sn.en and dt.data_set_id = #{dataset.id}")
      puts "************ time to update 'ka' common id and common name: #{Time.now-startPhase} seconds"

		end
    #logger.debug "++++procssed #{n} rows in CSV file"
  	puts "****************** time to build_from_csv: #{Time.now-start} seconds"

		# reset the locale
		I18n.locale = original_locale

    return msg
  end


	###################################
	## download data
	###################################
	# get all of the data for the event in a csv format
	def self.get_all_data_for_event(event_id, data_set_id)
		data = []
		if event_id && data_set_id
			event = Event.find(event_id)
			shape_types = ShapeType.by_event(event_id)

			if event && shape_types && !shape_types.empty?
				shape_types.each_with_index do |shape_type, index|
					d = get_table_data(event_id, data_set_id, shape_type.id, event.shape_id )

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

	def self.get_table_data(event_id, data_set_id, shape_type_id, shape_id)
		start = Time.now
		table = []
		ind_column_name = "ind"
		summary_column_name = "winner_ind"
		summary = [] # { :indicatory_type_id, :summary_name, :col_start_index, :col_end_index}

		if event_id && shape_type_id && shape_id && data_set_id

			# get all of the indicators for this event at this shape type
			ind_types = IndicatorType.find_by_event_shape_type(event_id, shape_type_id)

			core_ind_names = []
			core_ind_desc = []
			if ind_types && !ind_types.empty?
				# pull out the core indicator names and desc
				ind_ids = ind_types.map{|x| x.core_indicators.map{|y| y.indicators.map{|z| z.id}}}.flatten(2)
				core_ind_names = ind_types.map{|x| x.core_indicators.map{|y| y.core_indicator_translations[0].name}}.flatten(1)
				core_ind_desc = ind_types.map{|x| x.core_indicators.map{|y| y.core_indicator_translations[0].description}}.flatten(1)

				# if ind type has summary, save info to be used for creating summary column(s)
				ind_types.each do |type|
					if type.has_summary
						s = Hash.new
						s[:indicator_type_id] = type.id
						s[:summary_name] = type.indicator_type_translations[0].summary_name
						s[:col_start_index] = core_ind_names.index(type.core_indicators.first.core_indicator_translations[0].name)
						s[:col_end_index] = core_ind_names.index(type.core_indicators.last.core_indicator_translations[0].name)
						summary << s

						# add summary name to id/desc
						ind_ids.insert(s[:col_start_index], summary_column_name)
						core_ind_desc.insert(s[:col_start_index], s[:summary_name])
					end
				end
			end

      # get the shapes we need data for
      shapes = Shape.get_shapes_by_type(shape_id, shape_type_id)

			if core_ind_names && !core_ind_names.empty? && shapes && !shapes.empty?
				# build sql query
				sql = "select et.name as 'event', stt.name_singular as 'shape_type', d.#{I18n.locale}_common_id as 'common_id', d.#{I18n.locale}_common_name as 'common_name', "
				core_ind_names.each_with_index do |core, i|
					# if this index is the start of a summary, add the summary column for placeholder later on
					index = summary.index{|x| x[:col_start_index] == i}
					if index
						sql << "null as '#{summary_column_name}#{summary[index][:indicator_type_id]}', "
					end

					sql << "sum(if(cit.name = \"#{core}\", d.value, null)) as '#{ind_column_name}#{i}' "
					sql << ", " if i < core_ind_names.length-1

				end

				sql << "from "
				sql << "events as e "
				sql << "inner join event_translations as et on et.event_id = e.id "
				sql << "inner join indicators as i on i.event_id = e.id "
				sql << "inner join core_indicators as ci on ci.id = i.core_indicator_id "
				sql << "inner join core_indicator_translations as cit on cit.core_indicator_id = ci.id "
				sql << "inner join data as d on d.indicator_id = i.id "
				sql << "inner join shape_type_translations as stt on stt.shape_type_id = i.shape_type_id "
				sql << "where "
				sql << "e.id = :event_id "
				sql << "and i.shape_type_id = :shape_type_id "
				sql << "and d.data_set_id = :data_set_id "
				sql << "and d.#{I18n.locale}_common_id in (:common_ids) "
				sql << "and d.#{I18n.locale}_common_name in (:common_names) "
				sql << "and et.locale = :locale "
				sql << "and cit.locale = :locale "
				sql << "and stt.locale = :locale "
				sql << "group by et.name, stt.name_singular, d.#{I18n.locale}_common_name, d.#{I18n.locale}_common_name "
				sql << "order by et.name, stt.name_singular, d.#{I18n.locale}_common_name "

				data = Datum.find_by_sql([sql, :event_id => event_id, :data_set_id => data_set_id,
					:shape_type_id => shape_type_id, :locale => I18n.locale,
					:common_ids => shapes.collect(&:shape_common_id),
					:common_names => shapes.collect(&:shape_common_name)])

				if data && !data.empty?
					# create header row
					header = []
				  header_starter = download_header.join("||").gsub("[Level]", data.first.attributes["shape_type"]).split("||")
          header << header_starter
				  core_ind_desc.each do |core|
				    header << core
				  end
					table << header.flatten
          #update list of indicator ids with header_starter
          ind_ids.insert(0,header_starter.clone).flatten!

					# add data
					data.each do |obj|
						row = []
            data_hash = obj.to_hash_data_table
					  # if need summary, add summary data
  					if summary && !summary.empty?
  						summary.each_with_index do |sum, index|
  						  # summary column number
  						  # use this to offset array index pointers below
  						  num_summary_col = index+1
  							# get max value
  							max = data_hash.keys[
  										sum[:col_start_index]+download_header.length+num_summary_col..sum[:col_end_index]+download_header.length+num_summary_col]
  										.select{|key| data_hash[key] if !data_hash[key].nil?}.map{|key| data_hash[key]}.max
  							# add name of ind that won
  							# - possible that all values are nil
  							if max.nil?
  							  data_hash["#{summary_column_name}#{sum[:indicator_type_id]}"] = I18n.t('app.msgs.no_data')
							  else
    							data_hash["#{summary_column_name}#{sum[:indicator_type_id]}"] =
    							  core_ind_names[data_hash.values.index{|x| x == max}-download_header.length-num_summary_col]
                end
  						end
  					end

						data_hash.each do |k,v|
							if k.index(ind_column_name) == 0
								# this is an indicator with a data value, format the value
								row << format_value(v)
							else
								row << v
							end
						end
						table << row
					end
				end
			end
		end

    # build indicator type ids hash if summary exists
    indicator_type_ids = {}
    if summary && !summary.empty?
      summary.each do |s|
        indicator_type_ids[s[:summary_name]] = s[:indicator_type_id]
      end
    end

		puts "/////// total time = #{Time.now-start} seconds"
    return {:data => table, :indicator_ids => ind_ids, :indicator_type_ids => indicator_type_ids}
	end


=begin
	###################################
	## delete data
	###################################
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
#logger.debug "------ delete data for shape type #{shape_type_id} and indicator #{indicator_id}"
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
#logger.debug "------ delete data for shape type #{shape_type_id}"
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
#logger.debug "------ delete all data for event #{event_id}"
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
=end


protected

	def self.format_value(value)
		if value.nil? || value == I18n.t('app.msgs.no_data')
			return I18n.t('app.msgs.no_data')
		else
			return ActionController::Base.helpers.number_with_delimiter(ActionController::Base.helpers.number_with_precision(value))
		end
	end

end
