class IndicatorType < ActiveRecord::Base
  translates :name, :description
  
  has_many :indicator_type_translations, :dependent => :destroy
  has_many :indicators
  accepts_nested_attributes_for :indicator_type_translations
  attr_accessible :id, :has_summary, :indicator_type_translations_attributes

  attr_accessor :locale
  
	# get all indicators by type for an event and shape type
	def self.find_by_event_shape_type(event_id, shape_type_id)
		if event_id.nil? || shape_type_id.nil?
			return nil		
		else
			Rails.cache.fetch("indicator_types_by_event_#{event_id}_shape_type_#{shape_type_id}_#{I18n.locale}") {
				includes(:indicator_type_translations, {:indicators => :indicator_translations})
				.where(:indicators => {:event_id => event_id, :shape_type_id => shape_type_id}, 
							:indicator_type_translations => {:locale => I18n.locale},
							:indicator_translations => {:locale => I18n.locale})
			}
#      where(:event_id => event_id, :shape_type_id => shape_type_id)
		end
	end

end
