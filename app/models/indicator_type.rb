class IndicatorType < ActiveRecord::Base
  translates :name, :description, :summary_name

  has_many :indicator_type_translations, :dependent => :destroy
  has_many :core_indicators
  has_many :event_indicator_relationships, :dependent => :destroy
  has_many :indicators, :through => :core_indicators
  accepts_nested_attributes_for :indicator_type_translations
  attr_accessible :id, :has_summary, :sort_order, :indicator_type_translations_attributes

  attr_accessor :locale, :local_event_id, :local_shape_type_id

  scope :has_summary, where(:has_summary => true)

  def self.sorted
    with_translations(I18n.locale).order("indicator_types.sort_order, indicator_type_translations.name")
  end

	# get all indicators by type for an event and shape type
	def self.find_by_event_shape_type(event_id, shape_type_id)
		if event_id.present? && shape_type_id.present?
=begin
			with_translations(I18n.locale)
			.includes({:core_indicators => :indicators})
			.where(:indicators => {:event_id => event_id, :shape_type_id => shape_type_id})
			.order("indicator_types.sort_order asc").each do |it|
				# save the params for later use
				it.local_event_id = event_id
				it.local_shape_type_id = shape_type_id
			end
=end
#			Rails.cache.fetch("indicator_types_by_event_#{event_id}_shape_type_#{shape_type_id}") {
				includes(:indicator_type_translations, {:core_indicators => [:core_indicator_translations, :indicators]})
				.where(:indicators => {:event_id => event_id, :shape_type_id => shape_type_id},
						:indicator_type_translations => {:locale => I18n.locale},
						:core_indicator_translations => {:locale => I18n.locale})
				.order("indicator_types.sort_order asc, core_indicator_translations.name_abbrv asc")
#			}
		else
			return nil
		end
	end


	# get all indicators by type for events and shape type
	def self.find_by_events_shape_type(event_ids, shape_type_id)
		if event_ids.present? && shape_type_id.present?
#			Rails.cache.fetch("indicator_types_by_event_#{event_id}_shape_type_#{shape_type_id}") {
				includes(:indicator_type_translations, {:core_indicators => [:core_indicator_translations, :indicators]})
				.where(:indicators => {:event_id => event_ids, :shape_type_id => shape_type_id, :visible => true},
						:indicator_type_translations => {:locale => I18n.locale},
						:core_indicator_translations => {:locale => I18n.locale})
				.order("indicator_types.sort_order asc, core_indicator_translations.name_abbrv asc")
#			}
		else
			return nil
		end
	end


	# in order to include the translations without having n+1 queries,
	# the find_by_event_shape_type method above had to be split into
	# two parts
	def core_indicators_with_translations
		core_indicators.with_translations(I18n.locale).includes(:indicators)
			.where(:indicators => {:event_id => local_event_id, :shape_type_id => local_shape_type_id})
			.order("core_indicator_translations.name asc")
	end

	# get indicator types in an event that have summaries
	def self.get_summary_indicator_types_in_event(event_id)
		if event_id
			# get ids of summary types in event
			ids = self.select("distinct indicator_types.id")
							.joins(:core_indicators => :indicators)
							.where(:indicators => {:event_id => event_id})
			# only get names of ones that have summaries
			self.with_translations(I18n.locale).has_summary
				.where("indicator_types.id in (?)", ids.collect(&:id))
				.order("indicator_type_translations.name ASC")
		end
	end
end
