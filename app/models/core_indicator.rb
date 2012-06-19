class CoreIndicator < ActiveRecord::Base
  translates :name, :name_abbrv, :description
  has_ancestry

  has_many :core_indicator_translations, :dependent => :destroy
  belongs_to :indicator_type
  has_many :indicators
  accepts_nested_attributes_for :core_indicator_translations
  attr_accessible :indicator_type_id, :number_format, :color, :ancestry, :core_indicator_translations_attributes
  attr_accessor :locale

  validates :indicator_type_id, :presence => true
  
  scope :l10n , joins(:core_indicator_translations).where('locale = ?',I18n.locale)
  scope :by_name , order('name').l10n


  def self.order_by_type_name
    joins(:core_indicator_translations).where(:core_indicator_translations => {:locale => I18n.locale})
      .order("core_indicators.indicator_type_id ASC, core_indicator_translations.name ASC")
  end
end
