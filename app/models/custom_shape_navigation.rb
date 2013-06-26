class CustomShapeNavigation < ActiveRecord::Base
  translates :link_text

  belongs_to :event
  belongs_to :shape_type

  has_many :custom_shape_navigation_translations, :dependent => :destroy
  accepts_nested_attributes_for :custom_shape_navigation_translations
  attr_accessible :event_id, :shape_type_id, :sort_order, :always_visible, 
    :show_at_shape_type_id, :custom_shape_navigation_translations_attributes

  validates :event_id, :shape_type_id, :presence => true

  def self.with_sort_order
    with_translations(I18n.locale)
      .order("custom_shape_navigation.sort_order ASC, custom_shape_navigation_translations.link_text ASC")
  end

  def clone_for_event(event_id)
    if event_id.present?
      new_view = CustomShapeNavigation.new(:event_id => event_id, :shape_type_id => self.shape_type_id, 
            :sort_order => self.sort_order, :always_visible => self.always_visible, 
            :show_at_shape_type_id => self.show_at_shape_type_id)
      self.custom_shape_navigation_translations.each do |trans|
        new_view.custom_shape_navigation_translations.build(:locale => trans.locale, :link_text => trans.link_text)
      end
      new_view.save
    end
  end

end
