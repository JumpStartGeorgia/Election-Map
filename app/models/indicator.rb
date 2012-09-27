class Indicator < ActiveRecord::Base
  has_ancestry

  belongs_to :core_indicator
  has_one :indicator_type, :through => :core_indicator
  has_many :indicator_scales, :dependent => :destroy
  has_many :data, :dependent => :destroy
  belongs_to :event
  belongs_to :shape_type
  attr_accessible :core_indicator_id, :event_id, :shape_type_id, :visible, :ancestry

  validates :core_indicator_id, :event_id, :shape_type_id, :presence => true

#  scope :l10n , joins(:indicator_translations).where('locale = ?',I18n.locale)
#  scope :by_name , order('name').l10n


  def name
    self.core_indicator.name
  end

  def name_abbrv
    self.core_indicator.name_abbrv
  end

  def name_abbrv_w_parent
    self.core_indicator.name_abbrv_w_parent
  end

  def description
    self.core_indicator.description
  end

  def description_w_parent
    self.core_indicator.description_w_parent
  end

  def number_format
    self.core_indicator.number_format
  end

	# the shape_type has changed, get the indicator that
  # matches the indicator from the last shape type
	def self.find_new_id(old_indicator_id, new_shape_type_id)
		if old_indicator_id && new_shape_type_id
      new_indicator = Indicator.find(old_indicator_id).root.subtree.where(:shape_type_id => new_shape_type_id)
      if new_indicator && !new_indicator.empty?
        return new_indicator.first
      end
    end
	end

	def self.find_by_event_shape_type(event_id, shape_type_id)
		if event_id.nil? || shape_type_id.nil?
			return nil
		else
#			Rails.cache.fetch("indicators_by_event_#{event_id}_shape_type_#{shape_type_id}_#{I18n.locale}") {
				includes({:core_indicator => :core_indicator_translations})
				.where(:indicators => {:event_id => event_id, :shape_type_id => shape_type_id},
							:core_indicator_translations => {:locale => I18n.locale})
#			}
		end
	end

  def self.csv_all_header
    "Event, Shape Type, en: Indicator Type, en: Indicator Name, ka: Indicator Name, Visible, en: Scale Name, ka: Scale Name, Scale Color, en: Scale Name, ka: Scale Name, Scale Color".split(",")
  end

  def self.csv_scale_header
    "en: Scale Name, ka: Scale Name, Scale Color".split(",")
  end

  def self.csv_name_header
    "Event, Shape Type, Indicator Type, en: Indicator Name, ka: Indicator Name, Visible".split(",")
  end

  def self.csv_change_name_header
    "Event, Shape Type, en: Indicator Type, OLD en: Indicator Name, NEW en: Indicator Name, NEW en: Indicator Abbrv, NEW en: Indicator Description, NEW ka: Indicator Name, NEW ka: Indicator Abbrv, NEW ka: Indicator Description, Number Format (optional - e.g., %)".split(",")
  end

  def self.build_from_csv(file, deleteExistingRecord)
    infile = file.read
    n, msg = 0, ""
    idx_event = 0
    idx_shape_type = 1
    idx_indicator_type = 2
    idx_en_ind_name = 3
    idx_ka_ind_name = 4
    idx_visible = 5
    index_first_scale = 6
    columns_per_scale = 7

		Indicator.transaction do
		  CSV.parse(infile) do |row|
        num_colors_found_for_indicator = 0 # record number of colors found

		    n += 1
		    # SKIP: header i.e. first row OR blank row
		    next if n == 1 or row.join.blank?
    logger.debug "++++processing row #{n}"

        # if the event or shape type are not provided, stop
        if row[idx_event].nil? || row[idx_event].strip.length == 0 || row[idx_shape_type].nil? || row[idx_shape_type].strip.length == 0 ||
            row[idx_indicator_type].nil? || row[idx_indicator_type].strip.length == 0 ||
						row[idx_en_ind_name].nil? || row[idx_en_ind_name].strip.length == 0
  logger.debug "+++++++ event, shape type, indicator type, or indicator name not provided"
    		  msg = I18n.t('models.indicator.msgs.no_event_shape_spreadsheet', :row_num => n)
  	      raise ActiveRecord::Rollback
    		  return msg
  			else
  				# get the event id
  				event = Event.find_by_name(row[idx_event].strip)
  				# get the shape type id
  				shape_type = ShapeType.find_by_name_singular(row[idx_shape_type].strip)
  				# get the indicator type id
  				indicator_type = IndicatorType.find_by_name(row[idx_indicator_type].strip)
					# get the core indicator id
					core_indicator = CoreIndicator.find_by_name(row[idx_en_ind_name].strip)

  				if event.nil? || shape_type.nil? || indicator_type.nil? || core_indicator.nil?
  	logger.debug "++++event or shape type or indicator type or core indicator was not found"
		  		  msg = I18n.t('models.indicator.msgs.no_event_shape_db', :row_num => n)
  		      raise ActiveRecord::Rollback
      		  return msg
  				else
		logger.debug "++++found event, shape type, indicator type and core indicator, seeing if record already exists"
						# see if indicator already exists for the provided event and shape_type
						alreadyExists = Indicator.select("indicators.id").includes(:core_indicator)
						  .where('indicators.event_id = ? and indicators.shape_type_id = ? and indicators.core_indicator_id = ? and core_indicators.indicator_type_id = ? ',
						    event.id, shape_type.id, indicator_type.id, core_indicator.id)

	          # if the indicator already exists and deleteExistingRecord is true, delete the indicator
	          if !alreadyExists.nil? && alreadyExists.length > 0 && deleteExistingRecord
	logger.debug "+++++++ deleting existing indicator"
              alreadyExists.each do |exists|
	              Indicator.destroy (exists.id)
	            end
	            alreadyExists = nil
	          end

						if alreadyExists.nil? || alreadyExists.empty?
		logger.debug "++++record does not exist, populate obj"
							# populate record
							ind = Indicator.new
							ind.event_id = event.id
							ind.shape_type_id = shape_type.id
							ind.core_indicator_id = core_indicator.id
							ind.visible = row[idx_visible]

						  # scales
						  finishedScales = false # keep looping until find empty cell
						  i = index_first_scale # where first scale starts
						  until finishedScales do
						    if row[i].nil? || row[i+1].nil?
						      # found empty cell, stop
						      finishedScales = true
						    else
						      # found scale, add it
						      scale = ind.indicator_scales.build
	    					  scale.color = row[i+2].strip if (!row[i+2].nil? && row[i+2].strip.length > 0)
									scale.indicator_scale_translations.build(:locale => 'en', :name => row[i].strip)
									scale.indicator_scale_translations.build(:locale => 'ka', :name => row[i+1].strip)

	                # remember if a color was found
	                num_colors_found_for_indicator+=1 if (!row[i+2].nil? && row[i+2].strip.length > 0)

									i+=columns_per_scale # move on to the next set of indicator scales
						    end
						  end
						  # save if no scales provided
						  #  or if scales color provided for all scales
						  #  or there were between 3 and 13 scales and no color
	  		logger.debug "+++++++ num of colors found for this row: #{num_colors_found_for_indicator} and scale length = #{ind.indicator_scales.length}"
	  		logger.debug "+++++++ i = #{i}, lower bound = #{(3*columns_per_scale + index_first_scale)}, upper bound = #{(13*columns_per_scale + index_first_scale)}"
						  if ((i==index_first_scale) ||
						      (num_colors_found_for_indicator > 0 && num_colors_found_for_indicator == ind.indicator_scales.length) ||
						      (i >= (3*columns_per_scale + index_first_scale) && i <= (13*columns_per_scale + index_first_scale)))
	  		logger.debug "++++saving record"
	  					  # Save if valid
	  				    if ind.valid?
	  				      ind.save
	  				    else
	  				      # an error occurred, stop
							    msg = I18n.t('models.indicator.msgs.not_valid', :row_num => n)
	  				      raise ActiveRecord::Rollback
	  				      return msg
	  				    end
					    else
					      # scales out of range, stop
					      msg = I18n.t('models.indicator.msgs.scales_out_range', :row_num => n)
					      raise ActiveRecord::Rollback
					      return msg
					    end
						else
			logger.debug "++++**record already exists!"
							msg = I18n.t('models.indicator.msgs.already_exists', :row_num => n)
				      raise ActiveRecord::Rollback
				      return msg
						end
  				end
  			end
  		end
		end
  logger.debug "++++procssed #{n} rows in CSV file"
    return msg
  end

  def self.create_csv(event_id, names_only)
		obj = OpenStruct.new
		obj.csv_data = nil
		obj.msg = nil

    if event_id.nil? || names_only.nil?
logger.debug "not all params provided"
			obj.msg = I18n.t('models.indicator.msgs.missing_paramters')
      return obj
    else
      # get all of the indicators for this event
      if names_only
logger.debug "getting indicator names only"
        indicators = Indicator.includes({:event => :event_translations}, {:shape_type => :shape_type_translations}, {:core_indicator => [:core_indicator_translations, {:indicator_type => :indicator_type_translations}]})
          .where("indicators.event_id = :event_id and event_translations.locale = :locale and shape_type_translations.locale = :locale and indicator_type_translations.locale = :locale ",
            :event_id => event_id, :locale => "en")
          .order("shape_types.id ASC, indicator_type_translations.name ASC, indicators.id ASC")
      else
logger.debug "getting all indicator info"
        indicators = Indicator.includes({:event => :event_translations}, {:shape_type => :shape_type_translations}, {:core_indicator => [:core_indicator_translations, {:indicator_type => :indicator_type_translations}]}, {:indicator_scales => :indicator_scale_translations})
          .where("indicators.event_id = :event_id and event_translations.locale = :locale and shape_type_translations.locale = :locale and indicator_type_translations.locale = :locale ",
            :event_id => event_id, :locale => "en")
          .order("shape_types.id ASC, indicator_type_translations.name ASC, indicators.id ASC, indicator_scales.id ASC")
      end

      if indicators.nil? || indicators.empty?
logger.debug "no indicators found"
				obj.msg = I18n.t('models.indicator.msgs.no_indicators')
        return obj
      else
logger.debug "creating csv rows"
        # create the csv data
        rows =[]
        max_num_scales = 0
        indicators.each do |ind|
          row = []
					# event name
          if ind.event.event_translations.nil? || ind.event.event_translations.empty?
logger.debug "no event translation found"
						obj.msg = I18n.t('models.indicator.msgs.no_event_trans')
            return obj
          else
            row << ind.event.event_translations[0].name
          end

					# shape type
          if ind.shape_type.shape_type_translations.nil? || ind.shape_type.shape_type_translations.empty?
logger.debug "no shape type translation found"
						obj.msg = I18n.t('models.indicator.msgs.no_shape_type_trans')
            return obj
          else
            row << ind.shape_type.shape_type_translations[0].name_singular
          end

					# indicator type
          if ind.indicator_type.indicator_type_translations.nil? || ind.indicator_type.indicator_type_translations.empty?
logger.debug "no indicator type translation found"
						obj.msg = I18n.t('models.indicator.msgs.no_indicator_type_trans')
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

					# visible
					row << ind.visible

          if !names_only
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
          header << csv_name_header
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
