class EventCustomView < ActiveRecord::Base
  translates :note

  has_many :event_custom_view_translations, :dependent => :destroy
	belongs_to :event
	belongs_to :shape_type
	belongs_to :descendant_shape_type, :class_name => "ShapeType", :foreign_key => "descendant_shape_type_id"

  accepts_nested_attributes_for :event_custom_view_translations
	attr_accessible :event_id, :shape_type_id, :descendant_shape_type_id, :is_default_view, :event_custom_view_translations_attributes
end
