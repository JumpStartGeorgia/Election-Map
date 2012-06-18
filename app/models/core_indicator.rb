class CoreIndicator < ActiveRecord::Base
  translates :name, :name_abbrv, :description

  has_many :core_indicator_translations, :dependent => :destroy
  accepts_nested_attributes_for :core_indicator_translations
  attr_accessible :indicator_type_id, :number_format, :core_indicator_translations_attributes
  attr_accessor :locale

  validates :indicator_type_id, :presence => true
  
  scope :l10n , joins(:core_indicator_translations).where('locale = ?',I18n.locale)
  scope :by_name , order('name').l10n
end
