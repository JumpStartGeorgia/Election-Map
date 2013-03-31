class CustomShapeNavigation < ActiveRecord::Base
  translates :link_text

  belongs_to :event
  belongs_to :shape_type

  has_many :custom_shape_navigation_translations, :dependent => :destroy
  accepts_nested_attributes_for :custom_shape_navigation_translations
  attr_accessible :event_id, :shape_type_id, :sort_order, :always_visible, :custom_shape_navigation_translations_attributes

  validates :event_id, :shape_type_id, :presence => true

  def self.with_sort_order
    with_translations(I18n.locale)
      .order("custom_shape_navigation.sort_order ASC, custom_shape_navigation_translations.link_text ASC")
  end

end
