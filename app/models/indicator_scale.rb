class IndicatorScale < ActiveRecord::Base
  translates :name
  require 'csv'
  require 'scale_colors'
  include ScaleColors
	require 'ostruct'

  belongs_to :indicator
  has_many :indicator_scale_translations, :dependent => :destroy
  accepts_nested_attributes_for :indicator_scale_translations
  attr_accessible :indicator_id, :color, :indicator_scale_translations_attributes
  attr_accessor :locale

  scope :l10n , joins(:indicator_scale_translations).where('locale = ?',I18n.locale)
  scope :by_name , order('name').l10n

  # have to turn this off so csv upload works since adding indicator and scale at same time, no indicator id exists yet
  #validates :indicator_id, :presence => true

	# get count of indicator scales for indicator
	def self.count_by_indicator(indicator_id)
		where(:indicator_id => indicator_id).count
	end

	# get an array of colors to use with the scales
  def self.get_colors(indicator_id)
		if !indicator_id.nil?
			# get the number of scales for the provided indicator_id
			num_levels = count_by_indicator(indicator_id)
logger.debug "+++ num of indicator scales = #{num_levels}"
			if !num_levels.nil?
        colors = ScaleColors.get_colors("OrRd", num_levels)
        colors = [] if colors.nil?
				return colors
			end
		end
		return nil
	end

	# get all indicator scales for an indicator
	def self.find_by_indicator_id(indicator_id)
		if !indicator_id.nil?
#			Rails.cache.fetch("indicator_scales_by_indicator_#{indicator_id}") {
				where(:indicator_id => indicator_id)
#			}
		end
	end

  def self.csv_all_header
    "Event, Shape Type, Indicatory Type, en: Indicator Name, ka: Indicator Name, en: Scale Name, ka: Scale Name, Scale Color, en: Scale Name, ka: Scale Name, Scale Color".split(",")
  end

  def self.csv_start_header
    "Event, Shape Type, Indicator Type, en: Indicator Name, ka: Indicator Name".split(",")
  end

  def self.csv_scale_header
    "en: Scale Name, ka: Scale Name, Scale Color".split(",")
  end

  def self.build_from_csv(file, deleteExistingRecord)
    infile = file.read
    n, msg = 0, ""
    idx_event = 0
    idx_shape_type = 1
    idx_indicator_type = 2
    idx_en_ind_name = 3
    idx_ka_ind_name = 4
    index_first_scale = 5
    columns_per_scale = 3

		IndicatorScale.transaction do
		  CSV.parse(infile) do |row|
        num_colors_found_for_indicator = 0 # record number of colors found

		    n += 1
		    # SKIP: header i.e. first row OR blank row
		    next if n == 1 or row.join.blank?
    logger.debug "processing row #{n}"

        # if the event or shape type are not provided, stop
        if row[idx_event].nil? || row[idx_event].strip.length == 0 || row[idx_shape_type].nil? || row[idx_shape_type].strip.length == 0 ||
            row[idx_indicator_type].nil? || row[idx_indicator_type].strip.length == 0
  logger.debug "+++++++ event or shape type or indicator type not provided"
    		  msg = I18n.t('models.indicator_scale.msgs.no_event_shape_spreadsheet', :row_num => n)
		      raise ActiveRecord::Rollback
    		  return msg
				else
  				# get the event id
  				event = Event.find_by_name(row[idx_event].strip)
  				# get the shape type id
  				shape_type = ShapeType.find_by_name_singular(row[idx_shape_type].strip)
  				# get the indicator type id
  				indicator_type = IndicatorType.find_by_name(row[idx_indicator_type].strip)

  				if event.nil? || shape_type.nil? || indicator_type.nil?
  	logger.debug "++++event or shape type or indicator type was not found"
      		  msg = I18n.t('models.indicator_scale.msgs.no_event_shape_db', :row_num => n)
  		      raise ActiveRecord::Rollback
      		  return msg
  				else
            # only conintue if all values are present
            if row[idx_en_ind_name].nil?
        		  msg = I18n.t('models.indicator_scale.msgs.missing_data_spreadsheet', :row_num => n)
  logger.debug "++++**missing data in row"
              raise ActiveRecord::Rollback
              return msg
            else
			logger.debug "+++ found event and shape type, seeing if indicator record exists"
							# see if indicator exists for the provided event and shape_type
							alreadyExists = Indicator.select("indicators.id").includes(:core_indicator => :core_indicator_translations)
								.where('indicators.event_id = ? and indicators.shape_type_id = ? and core_indicators.indicator_type_id = ? and core_indicator_translations.locale="en" and core_indicator_translations.name= ?',
									event.id, shape_type.id, indicator_type.id, row[idx_en_ind_name].strip)

		          # if the indicator already exists and deleteExistingRecord is true, delete the indicator scales
		          if !alreadyExists.nil? && alreadyExists.length > 0 && deleteExistingRecord
		logger.debug "+++ deleting existing indicator scales"
                  alreadyExists.each do |exists|
  		              IndicatorScale.destroy_all (["indicator_id = ?", exists.id])
                  end
		              alreadyExists[0].indicator_scales = []
		          end

							if !alreadyExists.nil? && alreadyExists.length > 0
			logger.debug "+++ indicator record exists, checking if indicator already has scales"
			          indicator = alreadyExists[0]

                if indicator.indicator_scales.nil? || indicator.indicator_scales.empty?
			logger.debug "+++ indicator record has no scales, adding"
  								# populate record
  							  finishedScales = false # keep looping until find empty cell
  							  i = index_first_scale # where first scale starts
  							  until finishedScales do
  							    if row[i].nil? || row[i+1].nil?
  							      # found empty cell, stop
  							      finishedScales = true
  							    else
  							      # found scale, add it
  							      scale = indicator.indicator_scales.build
  		    					  scale.color = row[i+2].strip if (!row[i+2].nil? && row[i+2].strip.length > 0)
  										scale.indicator_scale_translations.build(:locale => 'en', :name => row[i].strip)
  										scale.indicator_scale_translations.build(:locale => 'ka', :name => row[i+1].strip)

  		                # remember if a color was found
  		                num_colors_found_for_indicator+=1 if (!row[i+2].nil? && row[i+2].strip.length > 0)

  										i+=columns_per_scale # move on to the next set of indicator scales
  							    end
  							  end
  							  # save scales if color provided for all scales or
  							  #  there were between 3 and 13 scales and no color
  		  		logger.debug "+++ num of colors found for this row: #{num_colors_found_for_indicator} and scale length = #{indicator.indicator_scales.length}"
  		  		logger.debug "+++ i = #{i}, lower bound = #{(3*columns_per_scale + index_first_scale)}, upper bound = #{(13*columns_per_scale + index_first_scale)}"
  							  if ((num_colors_found_for_indicator > 0 && num_colors_found_for_indicator == indicator.indicator_scales.length) ||
  							      (i >= (3*columns_per_scale + index_first_scale) && i <= (13*columns_per_scale + index_first_scale)))

  		  		logger.debug "+++ saving record"
  		  					  # Save if valid
  		  				    if indicator.valid?
  		  				      indicator.save
  		  				    else
  		  				      # an error occurred, stop
  		  				      msg = I18n.t('models.indicator_scale.msgs.not_valid', :row_num => n)
  		  				      raise ActiveRecord::Rollback
  		  				      return msg
  		  				    end
  						    else
  						      # not enough colors or scales out of range
  						      msg = I18n.t('models.indicator_scale.msgs.colors_scales_out_range', :row_num => n)
  						      raise ActiveRecord::Rollback
  						      return msg
  						    end
  							else
			logger.debug "+++ **reacord already has scales!"
  					      msg = I18n.t('models.indicator_scale.msgs.already_exists', :row_num => n)
  					      raise ActiveRecord::Rollback
  					      return msg
  							end
							else
				logger.debug "+++ **record does not exist!"
					      msg = I18n.t('models.indicator_scale.msgs.not_exists', :row_num => n)
					      raise ActiveRecord::Rollback
					      return msg
							end
	  				end
  				end
  			end
  		end
		end
  logger.debug "+++ procssed #{n} rows in CSV file"
    return msg
  end


  def self.create_csv(event_id)
		obj = OpenStruct.new
		obj.csv_data = nil
		obj.msg = nil

    if event_id.nil?
logger.debug "not all params provided"
			obj.msg = I18n.t('models.indicator_scale.msgs.missing_paramters')
      return obj
    else
      # get all of the indicators for this event
logger.debug "getting all indicator info"
      indicators = Indicator.includes({:event => :event_translations}, {:shape_type => :shape_type_translations}, {:core_indicator => [:core_indicator_translations, {:indicator_type => :indicator_type_translations}]}, {:indicator_scales => :indicator_scale_translations})
        .where("indicators.event_id = :event_id and event_translations.locale = :locale and shape_type_translations.locale = :locale and indicator_type_translations.locale = :locale ",
          :event_id => event_id, :locale => "en")
          .order("shape_types.id ASC, indicator_type_translations.name ASC, indicators.id ASC, indicator_scales.id ASC")

      if indicators.nil? || indicators.empty?
logger.debug "no indicators found"
				obj.msg = I18n.t('models.indicator_scale.msgs.no_indicators')
        return obj
      else
logger.debug "creating csv rows"
        # create the csv data
        rows =[]
        max_num_scales = 0
        indicators.each do |ind|
          row = []
          if ind.event.event_translations.nil? || ind.event.event_translations.empty?
logger.debug "no event translation found"
						obj.msg = I18n.t('models.indicator_scale.msgs.no_event_trans')
            return obj
          else
            row << ind.event.event_translations[0].name
          end
          if ind.shape_type.shape_type_translations.nil? || ind.shape_type.shape_type_translations.empty?
logger.debug "no shape type translation found"
						obj.msg = I18n.t('models.indicator_scale.msgs.no_shpae_type_trans')
            return obj
          else
            row << ind.shape_type.shape_type_translations[0].name_singular
          end
          if ind.indicator_type.indicator_type_translations.nil? || ind.indicator_type.indicator_type_translations.empty?
logger.debug "no indicator type translation found"
						obj.msg = I18n.t('models.indicator_scale.msgs.no_indicator_type_trans')
            return obj
          else
            row << ind.indicator_type.indicator_type_translations[0].name
          end
          # get en
          ind.core_indicator.core_indicator_translations.each do |trans|
            if trans.locale == 'en'
              row << trans.name
            end
          end
          # get ka
          ind.core_indicator.core_indicator_translations.each do |trans|
            if trans.locale == 'ka'
              row << trans.name
            end
          end

          # add the scales
          i = 0
          ind.indicator_scales.each do |scale|
            scale.indicator_scale_translations.each do |scale_trans|
              row << scale_trans.name
            end
            row << scale.color
            # update the max num of scales if necesssary
            i=i+1
            max_num_scales = i if i > max_num_scales
          end

          # add the row to the rows array
          rows << row
        end

				# enclose each item in the rows array in ""
				# this is in case an item has a ',' in the text
				rows.each do |r|
					r.each do |c|
						c = "#{c}"
					end
				end

      		obj.csv_data = CSV.generate(:col_sep=>',') do |csv|
          # generate the header
          header = []
          header << csv_start_header
          (1..max_num_scales).each do |i|
            header << csv_scale_header
          end
          csv << header.flatten

          # add the rows
          rows.each do |r|
            csv << r
          end
        end

        return obj
      end
    end
  end


end
