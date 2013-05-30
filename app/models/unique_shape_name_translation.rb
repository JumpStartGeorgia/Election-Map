class UniqueShapeNameTranslation < ActiveRecord::Base
  attr_accessible :unique_shape_name_id, :common_name, :common_id, :locale, :summary
  belongs_to :unique_shape_name

  validates :common_name, :common_id, :locale, :presence => true
  # this will always call validation to fail due to the translations being 
  # created while the unique shape name is created.  probably way to fix
#  validates :shape_id, :presence => true  
  
end
