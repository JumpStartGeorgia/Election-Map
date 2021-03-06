class CoreIndicator < ActiveRecord::Base
  translates :name, :name_abbrv, :description, :summary
  has_ancestry

  has_many :core_indicator_translations, :dependent => :destroy
  belongs_to :indicator_type
  has_many :indicators, :dependent => :destroy
  has_many :events, :through => :indicators, :uniq => true
  has_many :event_types, :through => :events, :uniq => true
  has_many :event_indicator_relationships, :dependent => :destroy
  accepts_nested_attributes_for :core_indicator_translations
  attr_accessible :indicator_type_id, :number_format, :color, :ancestry, :core_indicator_translations_attributes
  attr_accessor :locale, :rank

	before_validation :reset_ancestry

  validates :indicator_type_id, :presence => true

  scope :with_colors , with_translations(I18n.locale).where("color is not null").order("color asc")

	# if ancestry is '', make it nil
	def reset_ancestry
		self.ancestry = nil if self.ancestry && self.ancestry.empty?
	end

  def self.order_by_type_name(include_ancestry = false)
    sort = "core_indicators.indicator_type_id ASC, core_indicator_translations.name ASC"
    if include_ancestry
      sort = "core_indicators.indicator_type_id ASC, core_indicators.ancestry asc, core_indicator_translations.name ASC"
    end
    with_translations(I18n.locale)
      .order(sort)
  end

  def name_abbrv_w_parent
    parent_abbrv = self.ancestry.nil? ? "" : " (#{self.parent.name_abbrv})"
    "#{self.name_abbrv}#{parent_abbrv}"
  end

  def description_w_parent
    parent_name = self.ancestry.nil? ? "" : " (#{self.parent.name})"
    "#{self.description}#{parent_name}"
  end

	# return the name with the rank
	def rank_name
    CoreIndicator.generate_rank_name(self.name, self.rank)
	end

  def rank_name_abbrv_w_parent
    parent_abbrv = self.ancestry.nil? ? "" : " (#{self.parent.name_abbrv})"
    CoreIndicator.generate_rank_name("#{self.name_abbrv}#{parent_abbrv}", self.rank)
  end


  # public method so pages that have this data can generate the rank name
  # - for example, json data that is not in model object form
  def self.generate_rank_name(name, rank)
    if rank.present?
      "##{rank} - #{name}"
    else
      name
    end
  end

	# if this is a child and no color exist, see if the parent has a color
	def indicator_color
	  if !self.color.nil? && !self.color.empty?
	  	self.color
		elsif !self.ancestry.nil? && !self.parent.color.nil? && !self.parent.color.empty?
	  	self.parent.color
		else
			nil
		end
	end

	# get array of ids
	# - used for validation in :default_core_indicator_id in event
	def self.ids
	  select('id').map{|x| x.id}
	end

	# get list of unique core indicators in event
	def self.get_unique_indicators_in_event(event_id)
		if event_id
			# get ids of core indicators in event
			ids = self.select("distinct core_indicators.id")
							.joins(:indicators)
							.where(:indicators => {:event_id => event_id})

			self.order_by_type_name
				.where("core_indicators.id in (?)", ids.map{|x| x[:id]})
		end
	end

  # determine if the core indicator belongs to an indicator type that has a summary
  def self.get_indicator_type_with_summary(core_indicator_id)
    if core_indicator_id
      core = find(core_indicator_id)

      if core && core.indicator_type.has_summary
        return core
      end
    end
  end

  def self.for_profiles
#TODO
    # hard code the shape type ids for now
    shape_type_ids = [1,3,7]

    # get ids of indicators that have relationships
    ids = CoreIndicator.select('distinct core_indicators.id, core_indicators.ancestry').joins(:event_indicator_relationships, :indicators).where("indicators.shape_type_id in (?)", shape_type_ids)

    # merge the id and ancestry ids into one array
    core_ids = []
    if ids.present?
      core_ids = ids.map{|x| x.id}
      core_ids << ids.select{|x| x.ancestry.present?}.map{|x| x.root_id}.uniq
      core_ids.flatten!
    end

    where("core_indicators.id in (?)", core_ids)
      .order_by_type_name(true)

#    joins(:event_indicator_relationships, :indicators).where("indicators.shape_type_id in (?)", shape_type_ids).order_by_type_name(true)

  end

  # get all core indicators that have a relationship
  # format: [{id, name, name_abbrv, summary, type_id, child_ids, event_types => [id, name, sort_order, events => [id, name, event_date, shape_id, data_type, data_set_id]]}]
  def self.build_event_json
    json = []
    types = EventType.sorted
    CoreIndicator.for_profiles.each do |core|
      # if the indicators is not a child or is a child and parent does not exist, add
      if (core.ancestry.nil? || json.index{|x| x[:id].to_s == core.ancestry}.nil?)
        ind = Hash.new
        json << ind
        ind[:id] = core.id
        ind[:name] = core.name
        ind[:name_abbrv] = core.name_abbrv
        ind[:summary] = core.summary
        ind[:type_id] = core.indicator_type_id
        ind[:child_ids] = []
        event_types = []
        ind[:event_types] = event_types
        types.each do |type|
          # get events ordered by most recent being first
          events = core.events.select{|x| x.event_type_id == type.id}.sort_by{|x| x[:event_date]}.reverse
          if events.present?
            event_type = Hash.new
            event_types << event_type
            event_type[:id] = type.id
            event_type[:name] = type.name
            event_type[:sort_order] = type.sort_order
            event_type[:events] = []
            events.each do |event|
              e = Hash.new
              event_type[:events] << e
              e[:id] = event.id
              e[:name] = event.name
              e[:event_date] = event.event_date
              e[:shape_id] = event.shape_id
              e[:shape_type_id] = event.shape.shape_type_id if event.shape_id.present?
              # see if event has official data
              # if not, see if have live data
              # if not, default to official
	            dataset = DataSet.current_dataset(event.id, Datum::DATA_TYPE[:official])
	            if dataset.present?
                e[:data_type] = Datum::DATA_TYPE[:official]
#		            e[:data_set_id] =  dataset.first.id
	            else
  	            dataset = DataSet.current_dataset(event.id, Datum::DATA_TYPE[:live])
	              if dataset.present?
                  e[:data_type] = Datum::DATA_TYPE[:live]
#		              e[:data_set_id] =  dataset.first.id
	              else
                  e[:data_type] = Datum::DATA_TYPE[:official]
#  		            e[:data_set_id] =  nil
	              end
	            end
            end
          end
        end
      else
        # indicators belongs to a parent
        # add the event types/events from this to the parent
        index = json.index{|x| x[:id].to_s == core.ancestry}
        parent = json[index] if index.present?
        if parent.present?
          # indicate that this indicator has children
          parent[:child_ids] << core.id
          types.each do |type|
            # get events ordered by most recent being first
            events = core.events.select{|x| x.event_type_id == type.id}.sort_by{|x| x[:event_date]}.reverse
            if events.present?
              # if parent does not have this event type, add it
              type_index = parent[:event_types].index{|x| x[:id] == type.id}
              if !type_index.present?
                # add type
                event_type = Hash.new
                parent[:event_types] << event_type
                event_type[:id] = type.id
                event_type[:name] = type.name
                event_type[:sort_order] = type.sort_order
                event_type[:events] = []
                # resort the event types
                parent[:event_types].sort_by!{|x| x[:sort_order]}
              end

              type_index = parent[:event_types].index{|x| x[:id] == type.id}

              # add events
              events.each do |event|
                # add event if it does not already exist
                if parent[:event_types][type_index][:events].index{|x| x[:id] == event.id}.blank?
                  e = Hash.new
                  parent[:event_types][type_index][:events] << e
                  e[:id] = event.id
                  e[:name] = event.name
                  e[:event_date] = event.event_date
                  e[:shape_id] = event.shape_id
                  e[:shape_type_id] = event.shape.shape_type_id
                  # see if event has official data
                  # if not, see if have live data
                  # if not, default to official
	                dataset = DataSet.current_dataset(event.id, Datum::DATA_TYPE[:official])
	                if dataset.present?
                    e[:data_type] = Datum::DATA_TYPE[:official]
  #		              e[:data_set_id] =  dataset.first.id
	                else
      	            dataset = DataSet.current_dataset(event.id, Datum::DATA_TYPE[:live])
	                  if dataset.present?
                      e[:data_type] = Datum::DATA_TYPE[:live]
  #		                e[:data_set_id] =  dataset.first.id
	                  else
                      e[:data_type] = Datum::DATA_TYPE[:official]
  #    		            e[:data_set_id] =  nil
	                  end
	                end
                end
              end

              # resort the events
             parent[:event_types][type_index][:events] = parent[:event_types][type_index][:events].sort_by{|x| x[:event_date]}.reverse
            end
          end
        end
      end
    end
    return json
  end

end
