class CoreIndicator < ActiveRecord::Base
  translates :name, :name_abbrv, :description
  has_ancestry

  has_many :core_indicator_translations, :dependent => :destroy
  belongs_to :indicator_type
  has_many :indicators
  has_many :event_indicator_relationships, :dependent => :destroy
  accepts_nested_attributes_for :core_indicator_translations
  attr_accessible :indicator_type_id, :number_format, :color, :ancestry, :core_indicator_translations_attributes
  attr_accessor :locale

  validates :indicator_type_id, :presence => true

  scope :with_colors , with_translations(I18n.locale).where("color is not null").order("color asc")

  def self.order_by_type_name
    with_translations(I18n.locale)
      .order("core_indicators.indicator_type_id ASC, core_indicator_translations.name ASC")
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

end
