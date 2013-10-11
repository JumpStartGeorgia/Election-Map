#class DataJson < ActiveRecord::Base
module DataJson

	require 'json'


  @@event = nil
  @@shape_types = nil
  @@summary_indicator_types = Hash.new
  @@summary_core_indicator_ids = []
  @@indicators = []
  @@core_indicators = Hash.new
  @@core_id_index = Hash.new
  @@shape_type_child_ids = Hash.new
  @@idx_shape_type = 0
  @@idx_parent_common_id = 1
  @@idx_parent_common_name = 2
  @@idx_common_id = 3
  @@idx_common_name = 4
  @@idx_first_ind = 5
  @@limit = 5

  def self.process_csv(event_id, data_type, precincts_completed, precincts_total, timestamp, file)
		start = Time.now
    infile = file.read
    n, msg = 0, ""
#    index_first_ind = 3
		original_locale = I18n.locale
    I18n.locale = :en
    custom_shape_views = nil
    data = nil
  
    Event.transaction do
      # get the event
		  @@event = Event.find(event_id)
		  if @@event.nil?
		    msg = I18n.t('models.datum.msgs.no_event_db')
	      raise ActiveRecord::Rollback
		    return msg
      end

      # get all shape types
      @@shape_types = ShapeType.sorted
		  if @@shape_types.nil?
		    msg = "no shape types"
	      raise ActiveRecord::Rollback
		    return msg
      end

      # for each shape type see if it has child ids
      # - call this here once instead of for each row
      @@shape_types.each do |type|
        @@shape_type_child_ids[type.id.to_s] = type.child_ids if type.child_ids.present?
      end

      # get all indicator types that have a summary
      I18n.available_locales.each do |locale|
        @@summary_indicator_types[locale] = IndicatorType.has_summary.with_translations(locale).map{|x| {:id => x.id, :name => x.name, :summary_name => x.summary_name}}
      end
      
      # see if this event has custom shape view
      custom_shape_views = EventCustomView.where(:event_id => @@event.id)
      
      data = CSV.parse(infile)
      puts "****************************************************"
      puts "************************** csv has #{data.length} rows"
      puts "****************************************************"
      
	    data.each do |row|
#break if n > 1

        startRow = Time.now
	      n += 1
        puts "@@@@@@@@@@@@@@@@@@ processing row #{n}"


        if n == 1 # header row
          msg = process_header_row(row)
          if msg.present?
			      raise ActiveRecord::Rollback
	    		  return msg
          end          
          

          # go to the next row
		      next
        
        end

        # get shape type id for this row
        shape_type = @@shape_types.select{|x| x.name_singular == row[@@idx_shape_type]}.first

        puts "++++++++++++++++++++++++++++++++++++++++++++++++"
        puts "++++++++++++++++++++++++ shape type = #{row[@@idx_shape_type]}"
        puts "++++++++++++++++++++++++++++++++++++++++++++++++"

				if shape_type.blank?
	  		  msg = I18n.t('models.datum.msgs.no_shape_db', :row_num => n)
			    raise ActiveRecord::Rollback
	  		  return msg
	  		end


        # if shape type is root, process root 
        if shape_type.is_root?
          puts "++++++++++++++++++++++++ this shape is root"
          process_data_set(shape_type, row, shape_type, [row])              
          
        end
        
        # if shape type has children shape types, look for row with the children shape.
        if @@shape_type_child_ids[shape_type.id.to_s].present?
          puts "++++++++++++++++++++++++ this shape has child shapes"
          @@shape_type_child_ids[shape_type.id.to_s].each do |child_id|
            puts "++++++++++++++++++++++++ - processing child shape #{child_id}"
            child_shape = @@shape_types.select{|x| x.id == child_id}.first
          
            if child_shape.present?
              # found child shape, get rows with this child shape
              child_rows = data.select{|x| x[@@idx_shape_type] == child_shape.name_singular && 
                                              x[@@idx_parent_common_id] == row[@@idx_common_id] && 
                                              x[@@idx_parent_common_name] == row[@@idx_common_name]}
              puts "++++++++++++++++++++++++ -- found #{child_rows.length} children shape rows"
              process_data_set(shape_type, row, child_shape, child_rows) if child_rows.present?
              
            
            end
          end
        end
          
        # if shape type has custom shape navigation, look for rows with the custom shape
        if custom_shape_views.index{|x| x.shape_type_id == shape_type.id}.present?
          puts "++++++++++++++++++++++++ this shape has a custom shape view"
          custom_shape_views.select{|x| x.shape_type_id == shape_type.id}.each do |custom_shape_view|
            puts "++++++++++++++++++++++++ - processing custom shape view #{custom_shape_view.descendant_shape_type_id}"
            custom_shape = @@shape_types.select{|x| x.id == custom_shape_view.descendant_shape_type_id}.first
            
            if custom_shape.present?
              # found custom shape, get rows with this custom shape
              child_rows = data.select{|x| x[@@idx_shape_type] == custom_shape.name_singular}

              puts "++++++++++++++++++++++++ -- found #{child_rows.length} children shape rows for this custom shape"
              process_data_set(shape_type, row, custom_shape, child_rows) if child_rows.present?
            
            end
          end
        end
        


      	puts "******** time to process row: #{Time.now-startRow} seconds"
        puts "************************ total time so far : #{Time.now-start} seconds"
      end
    end

    puts "++++procssed #{n} rows in CSV file"
  	puts "****************** time to process csv: #{Time.now-start} seconds"

		# reset the locale
		I18n.locale = original_locale

    return msg
      
  end



protected

  # process the headers and get the core indicators that are in this csv file
  def self.process_header_row(row)
    msg = ''
    puts "****************first row - getting indicators"
    # get the indicators for all shape types
    (@@idx_first_ind..row.length-1).each do |ind_index|
      puts "****************indicator index = #{ind_index}"

      puts "**************** - get core indicator"
      # use default locale first
      @@core_indicators[I18n.locale] = [] if @@core_indicators[I18n.locale].blank?
      core = CoreIndicator.for_csv_processing_by_name(row[ind_index], I18n.locale)

      if core.blank?
        # indicator not found
		    msg = I18n.t('models.datum.msgs.indicator_not_found', :name => row[ind_index])
		    raise ActiveRecord::Rollback
		    return msg
      else
        @@core_indicators[I18n.locale] << core.first
        core_id = core.first.id
        @@core_id_index[core.first.id.to_s] = ind_index
      end

      I18n.available_locales.each do |locale|
        if locale != I18n.locale # default locale already processed
          @@core_indicators[locale] = [] if @@core_indicators[locale].blank?

          core = CoreIndicator.for_csv_processing_by_id(core_id, locale)

          if core.blank?
            # indicator not found
				    msg = I18n.t('models.datum.msgs.indicator_not_found', :name => row[ind_index])
				    raise ActiveRecord::Rollback
				    return msg
          else
            @@core_indicators[locale] << core.first
            @@core_id_index[core.first.id.to_s] = ind_index
          end
        end
      end


			indicator = Indicator.select("indicators.id, indicators.shape_type_id")
				.where(:event_id => @@event.id, :core_indicator_id => core.first.id)

      if indicator.blank?
        # indicator not found
				msg = I18n.t('models.datum.msgs.indicator_not_found', :name => row[ind_index])
				raise ActiveRecord::Rollback
				return msg
      else
        # save the indciator
        @@indicators << indicator
      end
    end
    
    # create array of core ind ids that should be used in summary
    if @@summary_indicator_types[I18n.locale].present?
      @@summary_indicator_types[I18n.locale].each do |type|
        @@summary_core_indicator_ids << {:type_id => type[:id], :data => @@core_indicators[I18n.locale].select{|x| x.indicator_type_id == type[:id]}.map{|x| x.id}}
      end
    end  
    
    return msg
  end



  # for a given set of rows, create data json for each indicator in these rows
  def self.process_data_set(parent_shape_type, parent_row, child_shape_type, child_rows)
    raw_summary_json = []
  
    # create raw summary json for each row
    child_rows.each do |row|
      raw_summary_json << create_raw_summary_json(child_shape_type, row)
    end

    # create summary json for set if needed
    summary_json = build_summary_json(raw_summary_json, parent_shape_type, parent_row, child_shape_type, child_rows)
    
    # build json data for each indicator in row that has data
    json = build_json(raw_summary_json, parent_shape_type, parent_row, child_shape_type, child_rows)
    
    
    # write out to file
    I18n.available_locales.each do |locale|
      path = "#{Rails.root}/tmp/json/"
      summary_file = "parent_#{parent_shape_type.id}_shape_#{child_shape_type.id}_summary_#{locale}.json"
      File.open(path + summary_file, 'w') {|f| f.write(summary_json[locale].to_json)}    
      
      json[locale].each do |item|
        file = "parent_#{parent_shape_type.id}_shape_#{child_shape_type.id}_ind_#{item["indicator"]["id"]}_#{locale}.json"
        File.open(path + file, 'w') {|f| f.write(item.to_json)}    
      end      
    end

  end



  # build the summary json for the row for all locales
  # returns {:en => json, :ka => json, etc}
  def self.create_raw_summary_json(shape_type, row)
    summaries = Hash.new
    
    if @@summary_core_indicator_ids.present?
      I18n.available_locales.each do |locale|
        summaries[locale] = nil
        
        @@summary_core_indicator_ids.each do |summary_ids|
          # order the indicators by value
          values = []
          summary_ids[:data].each do |summary_id|
            values << {:id => summary_id, :index => @@core_id_index[summary_id.to_s], :value => row[@@core_id_index[summary_id.to_s]].to_f, :rank => nil}
          end
          # sort desc order
          values.sort!{|x,y| y[:value] <=> x[:value]}
          
          # build json
          summary_json = Hash.new
          summary_json["data"] = []
          summary_json["visible"] = true
          summary_json["has_openlayers_rule_value"] = true
          summary_json["total_ranks"] = nil
          summary_json["has_duplicates"] = false
 
          # create rank
          values.each_with_index do |value, i|
            value[:rank] = compute_placement(values, value[:value])

            if i == 0
              summary_json["total_ranks"] = value[:rank][:total]
              summary_json["has_duplicates"] = value[:rank][:has_duplicates]
            end

            summary_item = Hash.new
            summary_json["data"] << summary_item
            
            core = @@core_indicators[locale].select{|x| x.id == value[:id]}.first
            summary_item["value"] = value[:value].to_s
            summary_item["formatted_value"] = format_value(value[:value]).to_s
            summary_item["number_format"] = core.number_format
            summary_item["rank"] = value[:rank][:rank]
            summary_item["color"] = core.color
            ind = @@indicators[@@core_id_index[value[:id].to_s]-@@idx_first_ind].select{|x| x.shape_type_id == shape_type.id}.first
            summary_item["indicator_id"] = ind.present? ? ind.id : nil
            summary_item["core_indicator_id"] = value[:id]
            summary_item["indicator_type_id"] = summary_ids[:type_id]
            summary_item["indicator_type_name"] = @@summary_indicator_types[locale].select{|x| x[:id] == summary_ids[:type_id]}.map{|x| x[:name]}.first
            summary_item["has_openlayers_rule_value"] = false
            summary_item["visible"] = true
            summary_item["indicator_name_unformatted"] = core[:indicator_name_unformatted]
            summary_item["indicator_name"] = core[:indicator_name]
            summary_item["indicator_name_abbrv"] = core[:indicator_name_abbrv]
          end

          summaries[locale] = summary_json
        end
      end
    end
    return summaries
  end



  def self.build_summary_json(raw_summary_json, parent_shape_type, parent_row, child_shape_type, child_rows)
    summary_json = Hash.new
    
    if @@summary_core_indicator_ids.present?
      @@summary_core_indicator_ids.map{|x| x[:type_id]}.uniq.each do |ind_type_id|

        # see if there is a relationship defined for this event and ind type id
        relationships = EventIndicatorRelationship.where(:event_id => @@event.id, :indicator_type_id => ind_type_id)

        
        if relationships.present?
          I18n.available_locales.each do |locale|
            index = @@summary_indicator_types[locale].index{|x| x[:id] == ind_type_id}

            # create summary json
            summary_json[locale] = Hash.new
            
        	  summary_json[locale]["indicator"] = Hash.new
            summary_json[locale]["indicator"]["name"] = nil
		        summary_json[locale]["indicator"]["name_abbrv"] = index.nil? ? nil : @@summary_indicator_types[locale][index][:summary_name]
		        summary_json[locale]["indicator"]["description"] = index.nil? ? nil : @@summary_indicator_types[locale][index][:summary_name]
		        summary_json[locale]["indicator"]["number_format"] = nil
            summary_json[locale]["indicator"]["scales"] = [{:name => IndicatorScale.no_data_text(locale), :color => IndicatorScale::NO_DATA_COLOR }]
		        summary_json[locale]["indicator"]["scale_colors"] = [IndicatorScale::NO_DATA_COLOR]
		        summary_json[locale]["indicator"]["switcher_indicator_id"] = nil
            summary_json[locale]["view_type"] = "summary"

            # add the data
            summary_json[locale]["shape_data"] = create_relationship_json(relationships, locale, child_rows, child_shape_type,
                                                   nil, raw_summary_json, ind_type_id, true)
            
          end
        end
      end
    end
    
    return summary_json
  end




  def self.build_json(raw_summary_json, parent_shape_type, parent_row, child_shape_type, child_rows)
    puts "###############################################"
    puts "###############################################"
    puts "###############################################"
    puts "###############################################"
    json = Hash.new

    I18n.available_locales.each do |locale|
      data_items = [] 
      json[locale] = data_items
      
      # for each indicator, if relationship exists, build it
      @@core_indicators[locale].each do |core|
        puts "###############################################"
        puts "###############################################"
        puts "# building json for core = #{core.inspect}"
        relationships = EventIndicatorRelationship.where(:event_id => @@event.id, :core_indicator_id => core.id)    
      
        if relationships.present?
          puts "# core has relationships"
          ind = @@indicators[@@core_id_index[core.id.to_s]-@@idx_first_ind].select{|x| x.shape_type_id == child_shape_type.id}.first

          if ind.present?
            puts "## core has indicator, creating json for locale #{locale}"
          
            # create json
            data_item = Hash.new
            data_items << data_item
            
        	  data_item["indicator"] = Hash.new
            data_item["indicator"]["id"] = ind.id
            data_item["indicator"]["name"] = core[:indicator_name_unformatted]
	          data_item["indicator"]["name_abbrv"] = core[:indicator_name_abbrv]
	          data_item["indicator"]["description"] = core[:indicator_description]
	          data_item["indicator"]["number_format"] = core.number_format.blank? ? "" : core.number_format
            data_item["indicator"]["scales"] = IndicatorScale.for_indicator(ind.id)
	          data_item["indicator"]["scale_colors"] = IndicatorScale.get_colors(ind.id)
	          data_item["indicator"]["switcher_indicator_id"] = nil
            data_item["view_type"] = "normal"

			      # if this event has a custom view at this level, get indicator id for other shape level
			      new_indicator = nil
			      custom_view = EventCustomView.where(:event_id => @@event.id, :shape_type_id => parent_shape_type.id)
			      if custom_view.present?
				      new_indicator = Indicator.find_new_id(ind.id, custom_view.first.descendant_shape_type_id)
			      else
				      custom_view = EventCustomView.where(:descendant_shape_type_id => child_shape_type.id)
        			if custom_view.present?
					      new_indicator = Indicator.find_new_id(ind.id, custom_view.first.shape_type.child_ids.first)
				      end
			      end
			      if new_indicator.present?
				      # is custom view, update switcher indicator id
				      data_item["indicator"]["switcher_indicator_id"] = new_indicator.id
			      end

            # add the data
            data_item["shape_data"] = create_relationship_json(relationships, locale, child_rows, child_shape_type, ind.id, raw_summary_json)
          end
          
        end
      end
    end    

    return json
  end
  
  


  # for each relationship in the rel param, create the appropriate json
  def self.create_relationship_json(relationships, locale, rows, shape_type, indicator_id=nil, raw_summary_json=nil, indicator_type_id=nil, is_summary=false)
    all_row_data = []

    rows.each_with_index do |row, row_index|
      row_data = []
      all_row_data << row_data
      
      # create place holder for winning value of this shape
      data_hash = Hash.new
  	  row_data << data_hash

      shape_values = Hash.new
      data_hash["shape_values"] = shape_values
#	            shape_values["shape_id"] = shape_id
      shape_values["parent_id"] = nil
      shape_values["common_id"] = row[@@idx_common_id]
      shape_values["common_name"] = row[@@idx_common_name]
      shape_values["shape_name"] = row[@@idx_common_name]
      shape_values["value"] = I18n.t('app.msgs.no_data', :locale => locale)
      shape_values["color"] = nil
      shape_values["number_format"] = nil
      shape_values["precincts_completed_precent"] = nil
      shape_values["title"] = I18n.t('app.msgs.no_data', :locale => locale)
      shape_values["title_abbrv"] = nil
      shape_values["title_location"] = nil
      shape_values["title_precincts_completed"] = nil

      has_duplicates = false
      
      # create data item/summary json for each item in releationship
      relationships.each do |rel|
        if rel.related_indicator_type_id.present? && rel.related_indicator_type_id == indicator_type_id 
          puts "============================="
          puts "============================="
          puts "= processing ind type relationship for type #{rel.related_indicator_type_id}"
          if raw_summary_json.present?
            # get the summary for this indciator type
	          data = Marshal.load(Marshal.dump(raw_summary_json[row_index][locale]))
            if data.present?
              puts "== found raw summary for this row, adding item"
              data["visible"] = rel.visible
              data["has_openlayers_rule_value"] = rel.has_openlayers_rule_value

          		results = Hash.new
              results["summary_data"] = Hash.new
              results["summary_data"]["data"] = []
              results["summary_data"]["visible"] = data["visible"]
              results["summary_data"]["has_openlayers_rule_value"] = data['has_openlayers_rule_value']
              results["summary_data"]["total_ranks"] = data['total_ranks']
              results["summary_data"]["has_duplicates"] = data['has_duplicates']
              results["summary_data"]["data"] = data['data']
              
              # limit number of summary records
              if @@limit.present? && @@limit > 0
          			results["summary_data"]["data"] = data['data'][0..@@limit-1]
              else
          			results["summary_data"]["data"] = data['data']
              end

              # add this data to the overall json
              row_data << results
              
              # update the shape values if this is for summary json
              if is_summary && indicator_type_id.present?
                puts "============================="
                puts "==>> using data from this summary to set shape values"
                shape_values["value"] = results["summary_data"]["data"].first["indicator_name_abbrv"]
                shape_values["color"] = results["summary_data"]["data"].first["color"]
                shape_values["title"] = results["summary_data"]["data"].first["indicator_type_name"]
              end
              
            end
          end
        elsif rel.related_core_indicator_id.present?
          puts "============================="
          puts "============================="
          puts "= processing core indicator relationship #{rel.related_core_indicator_id}"
          related_index = @@core_id_index[rel.related_core_indicator_id.to_s]
          core = nil
          ind = nil
          if related_index.present?
            puts "== core inds = #{@@core_indicators[locale].map{|x| x.id}}"
            puts "== index of core indicator is #{related_index}; adjusted index is #{related_index-@@idx_first_ind}"
            core = @@core_indicators[locale][related_index-@@idx_first_ind]
            ind = @@indicators[@@core_id_index[rel.related_core_indicator_id.to_s]-@@idx_first_ind].select{|x| x.shape_type_id == shape_type.id}.first
          end
          
          if core.present? && ind.present?
            puts "== core = #{core.inspect}"
            puts "== ind = #{ind.inspect}"

            # see if indicator is part of indicator type that has summary
            # if so, get the summary info so can assign the overall placement and overall winner
            index = @@summary_core_indicator_ids.index{|x| x[:data].index{|x| x == rel.related_core_indicator_id}}
            if index.present?
              puts "== found core indicator in list of summary core indicators"
              # this indicator is part of a summary
              # -> find the summary
	            summary = raw_summary_json[row_index][locale]
              # get the data for this indicator
              summary_indicator = summary["data"].select{|x| x["core_indicator_id"] == rel.related_core_indicator_id}.first
              
              if summary_indicator.present?
                puts "== found summary indicator: #{summary_indicator.inspect}"
    						data_item = Hash.new
    						data_item["data_item"] = summary_indicator
							  data_item["data_item"]["visible"] = rel.visible
							  data_item["data_item"]["has_openlayers_rule_value"] = rel.has_openlayers_rule_value
    	        	row_data << data_item
            
                # add the placement of this indicator
							  # if value != no data
							  # if there are duplicate values (e.g., a tie) fix the rank accordingly
							  if summary_indicator["value"] != I18n.t('app.msgs.no_data', :locale => locale)
                  puts "=== adding placement of indicator"
							    #&& data["summary_data"][index]["value"] != "0"

	    						data_item = Hash.new
	    						data_item["data_item"] = {
                    "value" => summary_indicator["rank"].to_s,
                    "formatted_value" => summary_indicator["rank"].to_s,
                    "number_format" => " / #{summary["total_ranks"]}",
                    "rank" => nil,
                    "color" => nil,
                    "indicator_type_id" => nil,
                    "indicator_type_name" => summary_indicator["indicator_type_name"],
                    "core_indicator_id" => nil,
                    "indicator_id" => nil,
                    "indicator_name_unformatted" => nil,
                    "indicator_name" => I18n.t('app.common.overall_placement', :locale => locale),
                    "indicator_name_abbrv" => I18n.t('app.common.overall_placement', :locale => locale),
                    "has_openlayers_rule_value" => false,
                    "visible" => true
                  }
                  has_duplicates = summary["has_duplicates"]
	                data_item["data_item"]["number_format"] += " *" if has_duplicates

	    	        	row_data << data_item
							  end

                # add total # of indicators in the summary
                puts "=== adding total # of indicators in summary"
    						data_item = Hash.new
    						data_item["data_item"] = {
                  "value" => summary["data"].length,
                  "formatted_value" => summary["data"].length,
                  "number_format" => nil,
                  "rank" => nil,
                  "color" => nil,
                  "indicator_type_id" => nil,
                  "indicator_type_name" => summary_indicator["indicator_type_name"],
                  "core_indicator_id" => nil,
                  "indicator_id" => nil,
                  "indicator_name_unformatted" => nil,
                  "indicator_name" => I18n.t('app.common.total_participants', :locale => locale),
                  "indicator_name_abbrv" => I18n.t('app.common.total_participants', :locale => locale),
                  "has_openlayers_rule_value" => false,
                  "visible" => true
                }
    	        	row_data << data_item
              end

              # add the winner if this record is not it and if value != no data or 0
						  if summary_indicator["rank"] > 1 &&
								  summary["data"][0]["value"] != "0" &&
								  summary["data"][0]["value"] != I18n.t('app.msgs.no_data', :locale => locale)

                puts "=== adding winning indicator"
                winner = Marshal.load(Marshal.dump(summary["data"][0]))

                winner["indicator_name"].insert(0, "#{I18n.t('app.common.winner', :locale => locale)}: ")
                winner["indicator_name_abbrv"].insert(0, "#{I18n.t('app.common.winner', :locale => locale)}: ")
    						data_item = Hash.new
    						data_item["data_item"] = winner 
    	        	row_data << data_item
              end
            else
              puts "== core indicator is NOT in summary core indicators"
              # add the data item
              if core.present? && ind.present?
                puts "=== adding item"
    						data_item = Hash.new
    						data_item["data_item"] = {
                  "value" => row[related_index],
                  "formatted_value" => format_value(row[related_index]),
                  "number_format" => core.number_format,
                  "rank" => nil,
                  "color" => nil,
                  "indicator_type_id" => core.indicator_type_id,
                  "indicator_type_name" => @@summary_indicator_types[locale].select{|x| x[:id] == core.indicator_type_id}.map{|x| x[:name]}.first,
                  "core_indicator_id" => rel.related_core_indicator_id,
                  "indicator_id" => ind.present? ? ind.id : nil,
                  "indicator_name_unformatted" => core[:indicator_name_unformatted],
                  "indicator_name" => core[:indicator_name],
                  "indicator_name_abbrv" => core[:indicator_name_abbrv],
                  "has_openlayers_rule_value" => false,
                  "visible" => true
                }
		            data_item["data_item"]["visible"] = rel.visible
		            data_item["data_item"]["has_openlayers_rule_value"] = rel.has_openlayers_rule_value
    	        	row_data << data_item
              end
            end
          end
          
          # update the shape values if this is for data json and this is the indicator the json is for
          if !is_summary && indicator_id.present? && ind.id == indicator_id
            puts "============================="
            puts "==>> using data from this indicator to set shape values"
            shape_values["value"] = data_item["data_item"]["value"]
            shape_values["number_format"] = data_item["data_item"]["number_format"]
            shape_values["title"] = data_item["data_item"]["indicator_name"]
            shape_values["title_abbrv"] = data_item["data_item"]["indicator_name_abbrv"]
          end  	        	
          
        end
      end

      # add duplicate footnote if needed
      if has_duplicates
				data_item = Hash.new
				data_item["data_item"] = {
          "value" => nil,
          "formatted_value" => nil,
          "number_format" => nil,
          "rank" => nil,
          "color" => nil,
          "indicator_type_id" => nil,
          "indicator_type_name" => nil,
          "core_indicator_id" => nil,
          "indicator_id" => nil,
          "indicator_name_unformatted" => nil,
          "indicator_name" => "* #{I18n.t('app.common.footnote_duplicates', :locale => locale)}",
          "indicator_name_abbrv" => "* #{I18n.t('app.common.footnote_duplicates', :locale => locale)}",
          "has_openlayers_rule_value" => false,
          "visible" => true
        }
      	row_data << data_item
      end
    
    end
    
    return all_row_data
  end








	def self.format_value(value)
		if value.nil? || value == I18n.t('app.msgs.no_data')
			return I18n.t('app.msgs.no_data')
		else
			return ActionController::Base.helpers.number_with_delimiter(ActionController::Base.helpers.number_with_precision(value))
		end
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

		if data_ary.present? && value
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


end
