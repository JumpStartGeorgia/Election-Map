class EventCustomView < ActiveRecord::Base
  translates :note

  has_many :event_custom_view_translations, :dependent => :destroy
	belongs_to :event
	belongs_to :shape_type
	belongs_to :descendant_shape_type, :class_name => "ShapeType", :foreign_key => "descendant_shape_type_id"

  accepts_nested_attributes_for :event_custom_view_translations
	attr_accessible :event_id, :shape_type_id, :descendant_shape_type_id, :is_default_view, :event_custom_view_translations_attributes

  def self.get_by_descendant(event_id, descendant_shape_type_id)
    where(:event_id => event_id, :descendant_shape_type_id => descendant_shape_type_id) if event_id && descendant_shape_type_id
  end


  def clone_for_event(event_id)
    if event_id.present?
      new_view = EventCustomView.new(:event_id => event_id, :shape_type_id => self.shape_type_id,
            :descendant_shape_type_id => self.descendant_shape_type_id, :is_default_view => self.is_default_view)
      self.event_custom_view_translations.each do |trans|
        new_view.event_custom_view_translations.build(:locale => trans.locale, :note => trans.note)
      end
      new_view.save
    end
  end
end
