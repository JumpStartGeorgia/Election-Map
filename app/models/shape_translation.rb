class ShapeTranslation < ActiveRecord::Base
  attr_accessible :shape_id, :common_name, :common_id, :locale
  belongs_to :shape

  validates :common_name, :common_id, :locale, :presence => true
  # this will always call validation to fail due to the translations being 
  # created while the event is created.  probably way to fix
#  validates :shape_id, :presence => true  


end
