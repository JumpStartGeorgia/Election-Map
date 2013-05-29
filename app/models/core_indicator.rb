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
  attr_accessor :locale

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

	# get list of unique core indicators in event
	def self.get_unique_indicators_in_event(event_id)
		if event_id
			# get ids of core indicators in event
			ids = self.select("distinct core_indicators.id")
							.joins(:indicators)
							.where(:indicators => {:event_id => event_id})

			self.order_by_type_name
				.where("core_indicators.id in (?)", ids.collect(&:id))
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
    joins(:event_indicator_relationships).order_by_type_name(true)
  end

  # get all core indicators that have a relationship
  def self.build_event_json
    json = []
    types = EventType.all
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
                e = Hash.new
                parent[:event_types][type_index][:events] << e
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

              # resort the events
              parent[:event_types][type_index][:events].sort_by!{|x| x[:event_date]}
            end
          end
        end
      end
    end
    return json
  end

end
