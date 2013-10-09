#class DataJson < ActiveRecord::Base
module DataJson

	require 'json'


  def self.process_csv(event_id, data_type, precincts_completed, precincts_total, timestamp, file)
		start = Time.now
    infile = file.read
    n, msg = 0, ""
    event = nil
    shape_types = nil
    summary_indicator_types = nil
    summary_core_indicator_ids = []
    indicators = []
    core_indicators = []
    core_id_index = Hash.new
    idx_shape_type = 0
    idx_common_id = 1
    idx_common_name = 2
    index_first_ind = 3
		original_locale = I18n.locale
    I18n.locale = :en
  
    Event.transaction do
      # get the event
		  event = Event.find(event_id)
		  if event.nil?
		    msg = I18n.t('models.datum.msgs.no_event_db')
	      raise ActiveRecord::Rollback
		    return msg
      end

      # get all shape types
      shape_types = ShapeType.sorted
		  if shape_types.nil?
		    msg = "no shape types"
	      raise ActiveRecord::Rollback
		    return msg
      end

      # get all indicator types that have a summary
      summary_indicator_types = IndicatorType.has_summary.sorted.map{|x| {:id => x.id, :name => x.name}}

	    CSV.parse(infile) do |row|
break if n > 2 

        startRow = Time.now
	      n += 1
        puts "@@@@@@@@@@@@@@@@@@ processing row #{n}"


        if n == 1 # header row
          puts "****************first row - getting indicators"
          # get the indicators for all shape types
          (index_first_ind..row.length-1).each do |ind_index|
            puts "****************indicator index = #{ind_index}"

            puts "**************** - get core indicator"
            core = CoreIndicator.for_csv_processing(row[ind_index], I18n.locale)

            if core.blank?
              # indicator not found
							msg = I18n.t('models.datum.msgs.indicator_not_found', :name => row[ind_index])
							raise ActiveRecord::Rollback
							return msg
            else
              core_indicators << core.first
              core_id_index[core.first.id.to_s] = ind_index
            end


  					indicator = Indicator.select("indicators.id, indicators.shape_type_id")
  						.where(:event_id => event.id, :core_indicator_id => core.first.id)

            if indicator.blank?
              # indicator not found
							msg = I18n.t('models.datum.msgs.indicator_not_found', :name => row[ind_index])
							raise ActiveRecord::Rollback
							return msg
            else
              # save the indciator
              indicators << indicator
            end
          end
          
          # create array of core ind ids that should be used in summary
          if summary_indicator_types.present?
            summary_indicator_types.each do |type|
              summary_core_indicator_ids << {:type_id => type[:id], :data => core_indicators.select{|x| x.indicator_type_id == type[:id]}.map{|x| x.id}}
            end
          end
          

          # go to the next row
		      next
        
        end

        # get shape type id for this row
        shape_type = shape_types.select{|x| x.name_singular == row[idx_shape_type]}.first

				if shape_type.blank?
	  		  msg = I18n.t('models.datum.msgs.no_shape_db', :row_num => n)
			    raise ActiveRecord::Rollback
	  		  return msg
	  		end

        # build summary json for row
        if summary_core_indicator_ids.present?
          summary_core_indicator_ids.each do |summary_ids|
            # order the indicators by value
            values = []
            summary_ids[:data].each do |summary_id|
              values << {:id => summary_id, :index => core_id_index[summary_id.to_s], :value => row[core_id_index[summary_id.to_s]].to_f, :rank => nil}
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
              puts "///////////////////////////////"
              puts "/// - index = #{i}"
              value[:rank] = compute_placement(values, value[:value])

              if i == 0
                summary_json["total_ranks"] = value[:rank][:total]
                summary_json["has_duplicates"] = value[:rank][:has_duplicates]
              end

              summary_item = Hash.new
              summary_json["data"] << summary_item
              
              core = core_indicators.select{|x| x.id == value[:id]}.first
              summary_item["value"] = value[:value].to_s
              summary_item["formatted_value"] = format_value(value[:value]).to_s
              summary_item["number_format"] = core.number_format
              summary_item["rank"] = value[:rank][:rank]
              summary_item["color"] = core.color
              puts "/// - core_indicators length = #{core_indicators.length}; ind length = #{indicators.length}; index = #{core_id_index[value[:id].to_s]-index_first_ind}"
              ind = indicators[core_id_index[value[:id].to_s]-index_first_ind].select{|x| x.shape_type_id == shape_type.id}.first
              
              summary_item["indicator_id"] = ind.present? ? ind.id : nil
              summary_item["core_indicator_id"] = value[:id]
              summary_item["indicator_type_id"] = summary_ids[:type_id]
              summary_item["indicator_type_name"] = summary_indicator_types.select{|x| x[:id] == summary_ids[:type_id]}.map{|x| x[:name]}.first
              summary_item["has_openlayers_rule_value"] = false
              summary_item["visible"] = true
              summary_item["indicator_name_unformatted"] = core[:indicator_name_unformatted]
              summary_item["indicator_name"] = core[:indicator_name]
              summary_item["indicator_name_abbrv"] = core[:indicator_name_abbrv]
              puts "/////////// - end"
            end

            puts summary_json            

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
