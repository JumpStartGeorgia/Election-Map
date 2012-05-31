class ShapeTypeTranslation < ActiveRecord::Base
  attr_accessible :shape_type_id, :name_singular, :name_plural, :locale
  belongs_to :shape_type

  validates :name_singular, :name_plural, :locale, :presence => true
  # this will always call validation to fail due to the translations being 
  # created while the event is created.  probably way to fix
#  validates :shape_type_id, :presence => true  

  default_scope order('locale ASC, name_singular ASC')
end
