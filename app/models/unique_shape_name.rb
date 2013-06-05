class UniqueShapeName < ActiveRecord::Base
  translates :common_id, :common_name, :summary

  has_many :unique_shape_name_translations, :dependent => :destroy
  accepts_nested_attributes_for :unique_shape_name_translations
  attr_accessible :shape_type_id, :unique_shape_name_translations_attributes

  validates :shape_type_id, :presence => true


  def self.sorted
    with_translations(I18n.locale).order("unique_shape_name_translations.common_name asc")
  end

  def self.by_shape_types(ids)
    where(:shape_type_id => ids)
  end

  def self.get_districts
    by_shape_types([3,7]).sorted
  end

  def self.for_profiles
#TODO
    # hard code the shape type ids for now
    shape_type_ids = [3,7]
    where("unique_shape_names.shape_type_id in (?)", shape_type_ids).sorted
  end

  # format: [{shape_type_id, common_id, common_name, summary, event_types => [id, name, sort_order, events => [id, name, event_date, shape_id, data_type, data_set_id]]}]
  def self.build_event_json
    json = []

    shapes = UniqueShapeName.get_districts
    types = EventType.with_public_events

    shapes.each do |shape|
      s = Hash.new
      json << s
      s[:shape_type_id] = shape.shape_type_id
      s[:common_id] = shape.common_id
      s[:common_name] = shape.common_name
      s[:summary] = shape.summary
      event_types = []
      s[:event_types] = event_types
      
      types.each do |type|
        # get events ordered by most recent being first
        events = type.events.sort_by{|x| x.event_date}.reverse
        if events.present?
          # see if this shape is in any of these events
          matches = Shape.by_common_and_events(shape.shape_type_id, shape.common_id, shape.common_name, events.map{|x| x.id})
          matches.delete_if{|x| x[:shape_type_id].nil?}
          if matches.present?
            # found match so add event type and events
            event_type = Hash.new
            event_types << event_type
            event_type[:id] = type.id
            event_type[:name] = type.name
            event_type[:sort_order] = type.sort_order
            event_type[:has_summary] = false
            event_type[:default_indicator_id] = nil
            event_type[:events] = []
            event_type[:indicator_types] = []

            # add all indicators that are in this event type
            indicators = IndicatorType.find_by_events_shape_type(matches.map{|x| x[:event_id]}, shape.shape_type_id)
            if indicators.present?
              indicators.each do |ind_type|
                i_type = Hash.new
                event_type[:indicator_types] << i_type
                i_type[:id] = ind_type.id
                i_type[:has_summary] = ind_type.has_summary
                i_type[:name] = ind_type.name
                i_type[:summary_name] = ind_type.summary_name
                i_type[:indicators] = []
                ind_type.core_indicators.each do |core|
                  core_ind = Hash.new
                  i_type[:indicators] << core_ind
                  core_ind[:id] = core.id
                  core_ind[:name_abbrv] = core.name_abbrv_w_parent  
                  core_ind[:name] = core.description_w_parent
                end
              end
            end

            # add events
            matches.each do |match|
              # get event
              event = events.select{|x| x.id == match[:event_id]}.first
              if event.present?

                # if the default indicator for this event type is not set, find it
                if event_type[:default_indicator_id].nil?
                  # use this event to find out the default indicator and save for event type
                  # - assuming all events in this type have same default indicator
                  ind_types = IndicatorType.find_by_event_shape_type(match[:event_id], shape.shape_type_id)
                  if ind_types.present?
                    if ind_types.first.has_summary 
                      # has summary
                      event_type[:has_summary] = true
                      event_type[:default_indicator_id] = ind_types.first.id
                    else
                      # does not have summary, save first indicator
                      event_type[:default_indicator_id] = ind_types.first.core_indicators.first.id
                    end
                  end
                end

                e = Hash.new
                event_type[:events] << e
                e[:id] = event.id
                e[:name] = event.name
                e[:event_date] = event.event_date
                e[:shape_id] = event.shape_id
                e[:shape_type_id] = event.shape.shape_type_id
                e[:data_type] = Datum::DATA_TYPE[:official]
	              dataset = DataSet.current_dataset(event.id, e[:data_type])
	              if dataset && !dataset.empty?
		              e[:data_set_id] =  dataset.first.id
	              else
		              e[:data_set_id] =  nil
	              end
              end
            end
          end
        end
      end
    end
    return json
  end
end
