class IndicatorTranslationOld < ActiveRecord::Base
  attr_accessible :indicator_id, :name, :name_abbrv, :description, :locale
  belongs_to :indicator

  validates :name, :name_abbrv, :locale, :presence => true
  # this will always call validation to fail due to the translations being 
  # created while the event is created.  probably way to fix
#  validates :indicator_id, :presence => true  

  default_scope order('locale ASC, name ASC')
end
