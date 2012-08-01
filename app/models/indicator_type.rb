class IndicatorType < ActiveRecord::Base
  translates :name, :description

  has_many :indicator_type_translations, :dependent => :destroy
  has_many :core_indicators
  has_many :event_indicator_relationships, :dependent => :destroy
  has_many :indicators, :through => :core_indicators
  accepts_nested_attributes_for :indicator_type_translations
  attr_accessible :id, :has_summary, :sort_order, :indicator_type_translations_attributes

  attr_accessor :locale, :local_event_id, :local_shape_type_id

	# get all indicators by type for an event and shape type
	def self.find_by_event_shape_type(event_id, shape_type_id)
		if event_id.nil? || shape_type_id.nil?
			return nil
		else
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

end
