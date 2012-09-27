class CreateNewVpmIndicator < ActiveRecord::Migration
  def up
    # create core indicator
    core = CoreIndicator.create(:indicator_type_id => 1)
    core.core_indicator_translations.create(:locale => 'en', :name => 'Number of Precincts with votes per minute > 3', 
      :name_abbrv => 'VPM > 3', :description => 'Number of Precincts with votes per minute > 3')
    core.core_indicator_translations.create(:locale => 'ka', :name => 'უბნების რაოდენობა, სადაც ხმის მიცემა წუთში > 3', 
      :name_abbrv => 'ხმის მიცემა წუთში > 3', :description => 'უბნების რაოდენობა, სადაც ხმის მიცემა წუთში > 3')
      
    event_id = 31
    core_indicator_id = 7 # vpm > 3 (08-12) - use to copy scales
    vpm_id_mapping = [[7,2], [8,3], [9,4], [10,5], [11,6]]
    vpm_id_parents = vpm_id_mapping.map{|x| x[0]}
    vpm_id_children = vpm_id_mapping.map{|x| x[1]}
    shape_types = ShapeType.all
    # create indicators
    indicators = Indicator.select('id, shape_type_id, core_indicator_id').where(:event_id => event_id).order('shape_type_id')
    ind_shape_types = indicators.map{|x| x.shape_type_id}.uniq
    ind_shape_types.each do |ind_shape_type|
      shape_type = shape_types.select{|x| x.id == ind_shape_type}.first
      # only create records for non-precinct levels
      if shape_type && !shape_type.is_precinct?
        # get scales to copy
        scales = Indicator.where(:event_id => event_id, :core_indicator_id => vpm_id_parents.first, :shape_type_id => shape_type.id)
        if scales && !scales.empty?
          new_indicator = Indicator.create(:event_id => event_id, :core_indicator_id => core.id, :shape_type_id => shape_type.id)
          # if this is not root, add ancestry value
          if new_indicator.shape_type_id != 1
            parent_indicator = indicators.select{|x| x.shape_type_id == shape_type.parent_id && 
                x.core_indicator_id == new_indicator.core_indicator_id}.first

            if parent_indicator
              new_indicator.parent_id = parent_indicator.id
              new_indicator.save
            end
          end
          
          # create scales for new indicator by copying from previous vpm indicator
          scales.indicator_scales.each do |ind_scale|
            scale = IndicatorScale.create(:indicator_id => new_indicator.id)
            ind_scale.indicator_scale_translations.each do |ind_scale_trans|
              scale.indicator_scale_translations.create(:locale => ind_scale_trans.locale,
                :name => ind_scale_trans.name)
            end
          end
          
          # create data records for new indicator
          # - sum up all vpm values at this shape level for each uniq common name and save
          vpm_indicators = Indicator.where(["event_id = ? and shape_type_id = ? and core_indicator_id in (?)", event_id, shape_type_id, vpm_id_parents])
          DataSet.where(:event_id => event_id).each do |dataset|          
            # get all data records in this dataset for these indicators
            data = Datum.where(["data_set_id = ? and indicator_id in (?)", dataset.id, vpm_indicators.collect(&:id)])
            # for each unique common_name (shape)
            data.map{|x| x.en_common_name}.uniq.each do |common_name|
              data_record = data.select{|x| x.en_common_name == common_name}.first
              # get the sum for all records with this common_name
              value_sum = data.select{|x| x.en_common_name == common_name}.map{|x| x.value.to_f}.inject(0, :+)
              # create the data record
              Datum.create(:indicator_id => new_indicator.id, :data_set_id => dataset.id, :value => value_sum,
                :en_common_id => data_record.en_common_id,
                :en_common_name => data_record.en_common_name,
                :ka_common_id => data_record.ka_common_id,
                :ka_common_name => data_record.ka_common_name
              )
            end
          end
        end
      end
    end
      
  end

  def down
    trans = CoreIndicatorTranslations.where(:name => 'Number of Precincts with votes per minute > 3')
    CoreIndicator.find(trans.first.core_indicator_id).destroy_all
  end
end
