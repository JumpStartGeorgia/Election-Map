class IndicatorTypeTranslation < ActiveRecord::Base
  attr_accessible :indicator_type_id, :name, :description, :locale
  belongs_to :indicator

  validates :name, :locale, :presence => true
  # this will always call validation to fail due to the translations being 
  # created while the indicator type is created.  probably way to fix
#  validates :indicator_type_id, :presence => true  

  default_scope order('locale ASC, name ASC')
end
