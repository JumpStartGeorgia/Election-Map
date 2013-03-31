class CustomShapeNavigationTranslation < ActiveRecord::Base
  attr_accessible :custom_shape_navigation_id, :link_text, :locale
  belongs_to :custom_shape_navigation

  validates :link_text, :locale, :presence => true
  # this will always call validation to fail due to the translations being 
  # created while the event is created.  probably way to fix
#  validates :custom_shape_navigation_id, :presence => true  

end
