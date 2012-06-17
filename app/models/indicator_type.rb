class IndicatorType < ActiveRecord::Base
  translates :name, :description
  
  has_many :indicator_type_translations, :dependent => :destroy
  has_many :indicators
  accepts_nested_attributes_for :indicator_type_translations
  attr_accessible :id, :has_summary, :indicator_type_translations_attributes

  attr_accessor :locale
  
end
